#!/bin/bash

# 简化版 DMG 创建脚本
# 自动为 Flutter macOS 应用创建 DMG 安装包

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# 解析命令行参数
CUSTOM_OUTPUT=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            CUSTOM_OUTPUT="$2"
            shift 2
            ;;
        -h|--help)
            echo "使用方法: $0 [-o 输出文件名]"
            echo "选项:"
            echo "  -o, --output    指定输出 DMG 文件名"
            echo "  -h, --help      显示此帮助信息"
            exit 0
            ;;
        *)
            print_error "未知选项: $1"
            echo "使用 -h 查看帮助信息"
            exit 1
            ;;
    esac
done

# 检查是否在项目根目录
if [ ! -f "pubspec.yaml" ]; then
    print_error "请在 Flutter 项目根目录运行此脚本"
    exit 1
fi

# 查找 .app 文件
APP_PATH=""
if [ -d "build/macos/Build/Products/Release" ]; then
    APP_FILES=(build/macos/Build/Products/Release/*.app)
    if [ ${#APP_FILES[@]} -eq 1 ] && [ -d "${APP_FILES[0]}" ]; then
        APP_PATH="${APP_FILES[0]}"
    fi
fi

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    print_error "未找到 .app 文件"
    print_info "请先运行: flutter build macos --release"
    exit 1
fi

# 获取应用信息
APP_NAME=$(basename "$APP_PATH" .app)
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')

# 设置输出文件名
if [ -n "$CUSTOM_OUTPUT" ]; then
    OUTPUT_NAME="$CUSTOM_OUTPUT"
else
    OUTPUT_NAME="${APP_NAME}-${VERSION}.dmg"
fi

print_info "找到应用: $APP_NAME"
print_info "版本: $VERSION"
print_info "输出文件: $OUTPUT_NAME"

# 删除已存在的 DMG
[ -f "$OUTPUT_NAME" ] && rm "$OUTPUT_NAME"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
DMG_DIR="$TEMP_DIR/dmg"
mkdir -p "$DMG_DIR"

# 清理函数
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
        print_info "清理: 卸载 DMG..."
        hdiutil detach "$MOUNT_POINT" 2>/dev/null || hdiutil detach "$MOUNT_POINT" -force 2>/dev/null || true
    fi
}
trap cleanup EXIT

print_info "准备 DMG 内容..."

# 复制应用和创建 Applications 链接
cp -R "$APP_PATH" "$DMG_DIR/"
ln -s /Applications "$DMG_DIR/Applications"

# 创建临时 DMG
print_info "创建 DMG..."
TEMP_DMG="$TEMP_DIR/temp.dmg"
hdiutil create -srcfolder "$DMG_DIR" -volname "$APP_NAME" -fs HFS+ -format UDRW -size 200m "$TEMP_DMG"

# 挂载并配置
print_info "配置 DMG 布局..."
MOUNT_OUTPUT=$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG")

# 更robust的挂载点解析逻辑
MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep -E '/Volumes/' | awk -F'\t' '{print $NF}' | head -1)
if [ -z "$MOUNT_POINT" ]; then
    # 备用解析方法
    MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep -E '^/dev/' | awk '{for(i=3;i<=NF;i++) printf "%s%s", $i, (i==NF?"":" ")}' | head -1)
fi

if [ -z "$MOUNT_POINT" ] || [ ! -d "$MOUNT_POINT" ]; then
    print_error "DMG 挂载失败"
    echo "挂载输出: $MOUNT_OUTPUT"
    echo "解析的挂载点: '$MOUNT_POINT'"
    exit 1
fi

print_info "DMG 已挂载到: $MOUNT_POINT"

# 使用 AppleScript 配置 Finder 视图
osascript <<EOF
tell application "Finder"
    tell disk "$APP_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 450}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 72
        set position of item "$APP_NAME.app" of container window to {150, 200}
        set position of item "Applications" of container window to {350, 200}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

sleep 2

# 卸载临时 DMG
print_info "卸载 DMG..."
if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
    if hdiutil detach "$MOUNT_POINT" 2>/dev/null; then
        print_info "DMG 卸载成功"
    else
        print_warning "DMG 卸载失败，尝试强制卸载..."
        hdiutil detach "$MOUNT_POINT" -force || true
    fi
else
    print_warning "挂载点不存在或已卸载"
fi
MOUNT_POINT=""

# 创建最终压缩 DMG
print_info "压缩 DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$OUTPUT_NAME"

# 验证
if hdiutil verify "$OUTPUT_NAME" >/dev/null 2>&1; then
    FILE_SIZE=$(du -h "$OUTPUT_NAME" | cut -f1)
    print_success "DMG 创建成功: $OUTPUT_NAME ($FILE_SIZE)"
    print_info "测试命令: open \"$OUTPUT_NAME\""
else
    print_error "DMG 验证失败"
    exit 1
fi