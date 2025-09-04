# GitHub Actions 状态徽章

在项目的 README.md 中添加以下徽章来显示构建状态：

## 构建状态徽章

### 主要工作流程状态
```markdown
![Build on Push](https://github.com/YOUR_USERNAME/gotify_client_flutter/workflows/Build%20on%20Push/badge.svg)
![CI/CD Pipeline](https://github.com/YOUR_USERNAME/gotify_client_flutter/workflows/CI%2FCD%20Pipeline/badge.svg)
![Release](https://github.com/YOUR_USERNAME/gotify_client_flutter/workflows/Release/badge.svg)
```

### 特定分支状态
```markdown
![Build Status](https://github.com/YOUR_USERNAME/gotify_client_flutter/workflows/Build%20on%20Push/badge.svg?branch=main)
```

### 最新发布版本
```markdown
![Latest Release](https://img.shields.io/github/v/release/YOUR_USERNAME/gotify_client_flutter)
![Release Date](https://img.shields.io/github/release-date/YOUR_USERNAME/gotify_client_flutter)
```

### 下载统计
```markdown
![Downloads](https://img.shields.io/github/downloads/YOUR_USERNAME/gotify_client_flutter/total)
![Latest Downloads](https://img.shields.io/github/downloads/YOUR_USERNAME/gotify_client_flutter/latest/total)
```

### 代码质量
```markdown
![Code Size](https://img.shields.io/github/languages/code-size/YOUR_USERNAME/gotify_client_flutter)
![Repo Size](https://img.shields.io/github/repo-size/YOUR_USERNAME/gotify_client_flutter)
![License](https://img.shields.io/github/license/YOUR_USERNAME/gotify_client_flutter)
```

### Flutter 相关
```markdown
![Flutter Version](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.8.1-blue.svg)
```

### 平台支持
```markdown
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
```

## 使用说明

1. 将上述代码中的 `YOUR_USERNAME` 替换为你的 GitHub 用户名
2. 将 `gotify_client_flutter` 替换为你的实际仓库名（如果不同）
3. 复制需要的徽章代码到你的 README.md 文件中

## 示例 README 头部

```markdown
# Gotify Client Flutter

![Build on Push](https://github.com/YOUR_USERNAME/gotify_client_flutter/workflows/Build%20on%20Push/badge.svg)
![Latest Release](https://img.shields.io/github/v/release/YOUR_USERNAME/gotify_client_flutter)
![Downloads](https://img.shields.io/github/downloads/YOUR_USERNAME/gotify_client_flutter/total)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![Flutter Version](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)
![License](https://img.shields.io/github/license/YOUR_USERNAME/gotify_client_flutter)

一个跨平台的 Gotify 客户端，使用 Flutter 构建。

## 功能特性
- 支持多平台：Android、iOS、Web、Windows、macOS、Linux
- 实时消息推送
- 系统托盘集成
- 桌面通知

## 下载

[![Latest Release](https://img.shields.io/github/v/release/YOUR_USERNAME/gotify_client_flutter)](https://github.com/YOUR_USERNAME/gotify_client_flutter/releases/latest)

从 [Releases 页面](https://github.com/YOUR_USERNAME/gotify_client_flutter/releases) 下载适合你平台的版本。
```

## 自定义徽章

你也可以使用 [shields.io](https://shields.io/) 创建自定义徽章：

```markdown
![Custom Badge](https://img.shields.io/badge/Gotify-Client-green)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Maintenance](https://img.shields.io/badge/Maintained-Yes-green)
```