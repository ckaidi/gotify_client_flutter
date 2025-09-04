#!/bin/bash

# Gotify Client Flutter 发布脚本
# 用于快速创建和发布新版本

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

# 检查是否在项目根目录
if [ ! -f "pubspec.yaml" ]; then
    print_error "请在项目根目录运行此脚本"
    exit 1
fi

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    print_warning "检测到未提交的更改:"
    git status --short
    echo
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "发布已取消"
        exit 1
    fi
fi

# 获取当前版本
current_version=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
print_info "当前版本: $current_version"

# 获取新版本号
if [ -z "$1" ]; then
    echo
    echo "请输入新版本号 (格式: x.y.z, 例如: 1.0.0):"
    read -p "新版本: " new_version
else
    new_version="$1"
fi

# 验证版本号格式
if [[ ! $new_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "版本号格式无效。请使用 x.y.z 格式 (例如: 1.0.0)"
    exit 1
fi

# 检查版本号是否已存在
if git tag | grep -q "^v$new_version$"; then
    print_error "版本 v$new_version 已存在"
    exit 1
fi

print_info "准备发布版本: $new_version"

# 确认发布
echo
print_warning "即将执行以下操作:"
echo "  1. 更新 pubspec.yaml 中的版本号"
echo "  2. 运行代码生成和测试"
echo "  3. 提交更改"
echo "  4. 创建并推送版本标签"
echo "  5. 触发 GitHub Actions 自动构建和发布"
echo
read -p "确认继续? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "发布已取消"
    exit 1
fi

print_info "开始发布流程..."

# 1. 更新版本号
print_info "更新版本号到 $new_version"
build_number=$(grep '^version:' pubspec.yaml | sed 's/.*+//')
new_build_number=$((build_number + 1))
sed -i.bak "s/^version: .*/version: $new_version+$new_build_number/" pubspec.yaml
rm pubspec.yaml.bak

# 2. 获取依赖
print_info "获取依赖包..."
flutter pub get

# 3. 运行代码生成
print_info "运行代码生成..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 4. 代码分析
print_info "运行代码分析..."
if ! flutter analyze; then
    print_error "代码分析失败，请修复问题后重试"
    exit 1
fi

# 5. 运行测试
print_info "运行测试..."
if ! flutter test; then
    print_error "测试失败，请修复问题后重试"
    exit 1
fi

# 6. 提交更改
print_info "提交版本更新..."
git add pubspec.yaml
git commit -m "chore: bump version to $new_version"

# 7. 创建标签
print_info "创建版本标签 v$new_version"
git tag -a "v$new_version" -m "Release version $new_version"

# 8. 推送更改和标签
print_info "推送到远程仓库..."
git push origin main
git push origin "v$new_version"

print_success "版本 v$new_version 发布成功!"
print_info "GitHub Actions 将自动开始构建和发布流程"
print_info "请访问 GitHub Actions 页面查看构建进度:"
echo "https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:\/]//' | sed 's/\.git$//')/actions"

print_info "发布完成后，可在以下页面下载构建产物:"
echo "https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:\/]//' | sed 's/\.git$//')/releases/tag/v$new_version"