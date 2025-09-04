# 脚本使用说明

本目录包含用于构建和发布 Gotify Flutter 客户端的各种脚本。

## 📁 脚本列表

### 🚀 发布脚本

#### `release.sh` (Linux/macOS)
自动化版本发布脚本，包含完整的发布流程。

**功能**:
- 更新版本号
- 运行代码生成和测试
- 提交更改并创建版本标签
- 推送到 GitHub 触发 CI/CD
- 在 macOS 上自动创建本地 DMG 文件

**使用方法**:
```bash
# 交互式发布
./scripts/release.sh

# 指定版本号
./scripts/release.sh 1.0.0
```

#### `release.bat` (Windows)
Windows 版本的发布脚本，功能与 `release.sh` 相同。

**使用方法**:
```cmd
REM 交互式发布
scripts\release.bat

REM 指定版本号
scripts\release.bat 1.0.0
```

### 📦 DMG 创建脚本 (macOS)

#### `create_dmg.sh` - 完整版
功能丰富的 DMG 创建脚本，支持自定义配置。

**功能**:
- 自定义 DMG 大小和卷名称
- 支持背景图片
- 完整的 Finder 视图配置
- 详细的命令行选项

**使用方法**:
```bash
# 基本使用（自动查找 .app 文件）
./scripts/create_dmg.sh

# 指定 .app 文件路径
./scripts/create_dmg.sh -a build/macos/Build/Products/Release/MyApp.app

# 完整配置
./scripts/create_dmg.sh \
  -a MyApp.app \
  -o MyApp-1.0.0.dmg \
  -n "My Application" \
  -v "My App Installer" \
  -s 150m \
  -b background.png
```

**选项说明**:
- `-a, --app-path`: 指定 .app 文件路径
- `-o, --output`: 指定输出 DMG 文件路径
- `-n, --app-name`: 指定应用名称
- `-v, --volume-name`: 指定 DMG 卷名称
- `-s, --size`: 指定 DMG 大小（默认: 100m）
- `-b, --background`: 指定背景图片路径
- `-h, --help`: 显示帮助信息

#### `create_dmg_simple.sh` - 简化版
简化的 DMG 创建脚本，适合日常使用。

**功能**:
- 自动查找 Flutter macOS 构建
- 自动获取版本号
- 标准化的 DMG 布局
- 一键创建

**使用方法**:
```bash
# 在项目根目录运行
./scripts/create_dmg_simple.sh
```

**前提条件**:
- 必须在 Flutter 项目根目录运行
- 需要先运行 `flutter build macos --release`

## 🔧 使用流程

### 日常开发
1. 开发功能
2. 提交代码到功能分支
3. 创建 Pull Request
4. 合并到主分支

### 发布新版本
1. 确保代码已合并到主分支
2. 在本地主分支运行发布脚本:
   ```bash
   ./scripts/release.sh 1.0.0
   ```
3. 脚本会自动:
   - 更新版本号
   - 运行测试
   - 创建版本标签
   - 推送到 GitHub
   - 在 macOS 上创建本地 DMG
4. GitHub Actions 会自动构建所有平台的安装包

### 仅创建 macOS DMG
如果只需要创建 macOS DMG 文件:

1. 构建 macOS 应用:
   ```bash
   flutter build macos --release
   ```

2. 创建 DMG:
   ```bash
   # 简化版（推荐）
   ./scripts/create_dmg_simple.sh
   
   # 或完整版
   ./scripts/create_dmg.sh
   ```

## 📋 输出文件

### 发布脚本输出
- 更新的 `pubspec.yaml`（版本号）
- Git 提交和标签
- 本地 DMG 文件（仅 macOS）

### DMG 脚本输出
- `AppName-Version.dmg`（简化版）
- 自定义名称的 DMG 文件（完整版）

## 🚨 注意事项

### 系统要求
- **macOS**: 所有脚本都支持
- **Linux**: 支持发布脚本，不支持 DMG 创建
- **Windows**: 支持 `release.bat`，不支持 DMG 创建

### 权限要求
- 脚本需要可执行权限
- DMG 创建需要 macOS 系统权限
- 发布脚本需要 Git 推送权限

### 依赖检查
运行脚本前确保已安装:
- Flutter SDK
- Git
- macOS 开发工具（DMG 创建）

## 🔍 故障排除

### 常见问题

1. **权限错误**
   ```bash
   chmod +x scripts/*.sh
   ```

2. **找不到 .app 文件**
   ```bash
   flutter build macos --release
   ```

3. **DMG 创建失败**
   - 检查是否在 macOS 系统上运行
   - 确保有足够的磁盘空间
   - 检查 Finder 是否正在运行

4. **版本标签已存在**
   ```bash
   git tag -d v1.0.0  # 删除本地标签
   git push origin :refs/tags/v1.0.0  # 删除远程标签
   ```

5. **测试失败**
   - 修复代码问题
   - 确保所有依赖已安装
   - 运行 `flutter pub get`

### 调试模式
在脚本中添加调试信息:
```bash
# 在脚本开头添加
set -x  # 显示执行的命令
set -e  # 遇到错误时退出
```

## 📚 相关文档

- [GitHub Actions 工作流程说明](../.github/README.md)
- [状态徽章配置](../.github/badges.md)
- [Flutter macOS 部署指南](https://docs.flutter.dev/deployment/macos)
- [DMG 创建最佳实践](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html)