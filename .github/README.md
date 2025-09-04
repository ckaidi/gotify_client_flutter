# GitHub Actions CI/CD 工作流程

本项目包含三个主要的 GitHub Actions 工作流程，用于自动化构建、测试和发布 Gotify Flutter 客户端。

## 📋 工作流程概览

### 1. 🔄 Build on Push (`build-on-push.yml`)
**触发条件**: 每次推送到 `main`、`develop` 或 `feature/*` 分支时

**功能**:
- 快速构建和测试（Ubuntu 环境）
- 代码分析和单元测试
- 构建 Android Debug APK 和 Web 版本
- 多平台构建矩阵（仅在 main 分支或 PR 时）

**适用场景**: 日常开发中的快速验证和测试

### 2. 🚀 CI/CD Pipeline (`ci-cd.yml`)
**触发条件**: 
- 推送到 `main` 或 `develop` 分支
- 针对 `main` 分支的 Pull Request
- 发布新版本时

**功能**:
- 完整的测试套件
- 构建所有平台的发布版本：
  - Android (APK + AAB)
  - iOS (IPA)
  - Web
  - Windows (ZIP)
  - macOS (ZIP)
  - Linux (TAR.GZ)
- 自动上传构建产物
- 发布时自动创建 GitHub Release

### 3. 📦 Release (`release.yml`)
**触发条件**:
- 推送版本标签 (如 `v1.0.0`)
- 手动触发工作流程

**功能**:
- 创建正式发布版本
- 构建所有平台的发布版本
- 自动上传到 GitHub Releases
- 包含详细的发布说明

## 🛠️ 使用指南

### 日常开发
1. 创建功能分支: `git checkout -b feature/your-feature`
2. 提交代码: `git push origin feature/your-feature`
3. 自动触发快速构建和测试

### 发布新版本

#### 方法一: 使用 Git 标签
```bash
# 创建并推送版本标签
git tag v1.0.0
git push origin v1.0.0
```

#### 方法二: 手动触发
1. 访问 GitHub Actions 页面
2. 选择 "Release" 工作流程
3. 点击 "Run workflow"
4. 输入版本号（如 v1.0.0）

### 版本号规范
- 使用语义化版本: `v主版本.次版本.修订版本`
- 示例: `v1.0.0`, `v1.2.3`, `v2.0.0-beta.1`

## 📁 构建产物

### 开发构建 (build-on-push)
- `quick-build-{commit-sha}`: 包含 Android Debug APK 和 Web 构建
- `{platform}-build-{commit-sha}`: 各平台的发布构建

### 正式发布 (release)
所有构建产物会自动上传到 GitHub Releases:
- `gotify-client-android.apk` - Android 安装包
- `gotify-client-android.aab` - Google Play 发布包
- `gotify-client-ios.ipa` - iOS 安装包
- `gotify-client-windows.zip` - Windows 可执行文件
- `gotify-client-macos.zip` - macOS 应用程序
- `gotify-client-linux.tar.gz` - Linux 可执行文件
- `gotify-client-web.zip` - Web 应用文件

## ⚙️ 配置说明

### Flutter 版本
当前使用 Flutter 3.24.0 稳定版。如需更新，请修改各工作流程文件中的 `FLUTTER_VERSION` 环境变量。

### 平台支持
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+ 或其他现代 Linux 发行版
- **Web**: 现代浏览器

### 依赖项
工作流程会自动安装以下依赖：
- Flutter SDK
- Java 17 (Android 构建)
- Linux 构建依赖 (clang, cmake, ninja-build, libgtk-3-dev 等)

## 🔧 故障排除

### 常见问题

1. **构建失败 - 依赖问题**
   - 检查 `pubspec.yaml` 中的依赖版本
   - 确保 `flutter pub get` 能正常运行

2. **代码生成失败**
   - 确保 `build_runner` 依赖已添加到 `dev_dependencies`
   - 检查生成的文件是否有语法错误

3. **平台特定构建失败**
   - 检查平台特定的配置文件
   - 确保所有必需的权限和配置已设置

4. **发布失败**
   - 确保有 `GITHUB_TOKEN` 权限
   - 检查版本标签格式是否正确

### 调试技巧

1. **查看构建日志**
   - 访问 GitHub Actions 页面查看详细日志
   - 关注失败步骤的错误信息

2. **本地测试**
   ```bash
   # 运行代码生成
   flutter packages pub run build_runner build --delete-conflicting-outputs
   
   # 代码分析
   flutter analyze
   
   # 运行测试
   flutter test
   
   # 构建特定平台
   flutter build android --release
   flutter build web --release
   ```

3. **缓存问题**
   - 工作流程使用缓存来加速构建
   - 如遇到缓存相关问题，可以在 Actions 页面清除缓存

## 📈 性能优化

- 使用 Flutter 缓存减少下载时间
- 并行构建多个平台
- 智能触发条件避免不必要的构建
- 构建产物保留期限设置（开发构建 7 天，发布构建 30 天）

## 🔒 安全考虑

- 使用官方 GitHub Actions
- 最小权限原则
- 敏感信息使用 GitHub Secrets
- 定期更新 Actions 版本

---

如有问题或建议，请创建 Issue 或 Pull Request。