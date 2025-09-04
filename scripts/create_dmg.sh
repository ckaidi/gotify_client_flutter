#!/bin/bash

# macOS DMG 创建脚本
# 用于将 .app 文件打包为 DMG 安装包

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示使用说明
show_usage() {
    echo "使用方法: $0 [选项]"
    echo "选项:"
    echo "  -a, --app-path PATH     指定 .app 文件路径"
    echo "  -o, --output PATH       指定输出 DMG 文件路径"
    echo "  -n, --app-name NAME     指定应用名称 (默认从 .app 文件名获取)"
    echo "  -v, --volume-name NAME  指定 DMG 卷名称 (默认使用应用名称)"
    echo "  -s, --size SIZE         指定 DMG 大小 (默认: 100m)"
    echo "  -b, --background PATH   指定背景图片路径 (可选)"
    echo "  -h, --help              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -a build/macos/Build/Products/Release/gotify_client_flutter.app"
    echo "  $0 -a MyApp.app -o MyApp-1.0.0.dmg -n \"My Application\""
}

# 默认值
APP_PATH=""
OUTPUT_PATH=""
APP_NAME=""
VOLUME_NAME=""
DMG_SIZE="100m"
BACKGROUND_PATH=""

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--app-path)
            APP_PATH="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        -n|--app-name)
            APP_NAME="$2"
            shift 2
            ;;
        -v|--volume-name)
            VOLUME_NAME="$2"
            shift 2
            ;;
        -s|--size)
            DMG_SIZE="$2"
            shift 2
            ;;
        -b|--background)
            BACKGROUND_PATH="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "未知选项: $1"
            show_usage
            exit 1
            ;;
    esac
done

# 如果没有指定 .app 路径，尝试自动查找
if [ -z "$APP_PATH" ]; then
    if [ -d "build/macos/Build/Products/Release" ]; then
        APP_FILES=(build/macos/Build/Products/Release/*.app)
        if [ ${#APP_FILES[@]} -eq 1 ] && [ -d "${APP_FILES[0]}" ]; then
            APP_PATH="${APP_FILES[0]}"
            print_info "自动找到 .app 文件: $APP_PATH"
        else
            print_error "在 build/macos/Build/Products/Release 中找到多个或没有 .app 文件"
            print_info "请使用 -a 选项指定 .app 文件路径"
            exit 1
        fi
    else
        print_error "请指定 .app 文件路径"
        show_usage
        exit 1
    fi
fi

# 检查 .app 文件是否存在
if [ ! -d "$APP_PATH" ]; then
    print_error ".app 文件不存在: $APP_PATH"
    exit 1
fi

# 获取应用名称
if [ -z "$APP_NAME" ]; then
    APP_NAME=$(basename "$APP_PATH" .app)
fi

# 设置卷名称
if [ -z "$VOLUME_NAME" ]; then
    VOLUME_NAME="$APP_NAME"
fi

# 设置输出路径
if [ -z "$OUTPUT_PATH" ]; then
    OUTPUT_PATH="${APP_NAME}.dmg"
fi

# 确保输出目录存在
OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
mkdir -p "$OUTPUT_DIR"

# 删除已存在的 DMG 文件
if [ -f "$OUTPUT_PATH" ]; then
    print_warning "删除已存在的 DMG 文件: $OUTPUT_PATH"
    rm "$OUTPUT_PATH"
fi

print_info "开始创建 DMG 文件..."
print_info "应用路径: $APP_PATH"
print_info "应用名称: $APP_NAME"
print_info "卷名称: $VOLUME_NAME"
print_info "输出路径: $OUTPUT_PATH"
print_info "DMG 大小: $DMG_SIZE"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
DMG_TEMP_DIR="$TEMP_DIR/dmg"
mkdir -p "$DMG_TEMP_DIR"

# 清理函数
cleanup() {
    print_info "清理临时文件..."
    rm -rf "$TEMP_DIR"
    # 卸载可能挂载的 DMG
    if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
        hdiutil detach "$MOUNT_POINT" 2>/dev/null || true
    fi
}

# 设置退出时清理
trap cleanup EXIT

# 复制 .app 文件到临时目录
print_info "复制应用文件..."
cp -R "$APP_PATH" "$DMG_TEMP_DIR/"

# 创建 Applications 链接
print_info "创建 Applications 链接..."
ln -s /Applications "$DMG_TEMP_DIR/Applications"

# 如果有背景图片，复制到临时目录
if [ -n "$BACKGROUND_PATH" ] && [ -f "$BACKGROUND_PATH" ]; then
    print_info "添加背景图片..."
    mkdir -p "$DMG_TEMP_DIR/.background"
    cp "$BACKGROUND_PATH" "$DMG_TEMP_DIR/.background/"
    BACKGROUND_FILE=".background/$(basename "$BACKGROUND_PATH")"
fi

# 创建临时 DMG
print_info "创建临时 DMG..."
TEMP_DMG="$TEMP_DIR/temp.dmg"
hdiutil create -srcfolder "$DMG_TEMP_DIR" -volname "$VOLUME_NAME" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size "$DMG_SIZE" "$TEMP_DMG"

# 挂载临时 DMG
print_info "挂载临时 DMG 进行配置..."
MOUNT_POINT=$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG" | grep -E '^/dev/' | sed 1q | awk '{print $3}')

if [ -z "$MOUNT_POINT" ]; then
    print_error "无法挂载临时 DMG"
    exit 1
fi

print_info "DMG 挂载点: $MOUNT_POINT"

# 配置 Finder 视图
print_info "配置 Finder 视图..."

# 创建 AppleScript 来配置 Finder 窗口
APPLESCRIPT="
tell application \"Finder\"
    tell disk \"$VOLUME_NAME\"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 450}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 72
        set background picture of viewOptions to file \".background:$(basename "$BACKGROUND_PATH")\" 
        set position of item \"$APP_NAME.app\" of container window to {150, 200}
        set position of item \"Applications\" of container window to {350, 200}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
"

# 如果没有背景图片，使用简化的 AppleScript
if [ -z "$BACKGROUND_PATH" ]; then
    APPLESCRIPT="
tell application \"Finder\"
    tell disk \"$VOLUME_NAME\"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 450}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 72
        set position of item \"$APP_NAME.app\" of container window to {150, 200}
        set position of item \"Applications\" of container window to {350, 200}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
"
fi

# 执行 AppleScript
echo "$APPLESCRIPT" | osascript

# 等待 Finder 完成配置
sleep 3

# 卸载临时 DMG
print_info "卸载临时 DMG..."
hdiutil detach "$MOUNT_POINT"
MOUNT_POINT=""

# 创建最终的压缩 DMG
print_info "创建最终的压缩 DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$OUTPUT_PATH"

# 验证 DMG
print_info "验证 DMG 文件..."
if hdiutil verify "$OUTPUT_PATH" >/dev/null 2>&1; then
    print_success "DMG 文件创建成功: $OUTPUT_PATH"
    
    # 显示文件信息
    FILE_SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
    print_info "文件大小: $FILE_SIZE"
    
    # 显示 DMG 信息
    print_info "DMG 信息:"
    hdiutil imageinfo "$OUTPUT_PATH" | grep -E "(Format|Compressed|Checksum)"
else
    print_error "DMG 文件验证失败"
    exit 1
fi

print_success "DMG 创建完成!"
print_info "可以使用以下命令测试 DMG:"
print_info "  open \"$OUTPUT_PATH\""