# 🚀 Gotify Flutter 桌面客户端

> ⚡ **AI 辅助开发项目** - 本项目使用人工智能技术辅助编码开发，结合人工监督和优化

一个现代化的跨平台 Gotify 桌面客户端，使用 Flutter 构建，支持实时接收和管理 Gotify 推送通知。

## ✨ 功能特性

- 🔄 **实时通信**：WebSocket 连接确保即时接收通知
- 🖥️ **跨平台支持**：原生支持 macOS、Windows、Linux
- 📱 **桌面通知**：系统级通知推送，不错过任何消息
- 🏠 **系统托盘**：点击关闭按钮隐藏到托盘，后台继续运行
- 🔌 **智能重连**：网络中断时自动重连，确保连接稳定
- 📜 **消息管理**：完整的消息历史记录和查看功能
- ⚙️ **灵活配置**：可自定义服务器设置、通知选项等
- 🎨 **现代界面**：Material Design 3 设计语言
- 🔧 **开发友好**：完整的调试功能和状态监控

## 💻 技术栈

### 核心技术
- **Flutter 3.8.1+**: 跨平台UI框架
- **Dart**: 高效的编程语言
- **Material Design 3**: 现代化设计系统

### 主要依赖库
- 🌐 **网络通信**
  - `web_socket_channel ^2.4.0`: WebSocket 实时连接
  - `http ^1.1.0`: HTTP 请求处理

- 🧩 **桌面集成**
  - `local_notifier ^0.1.6`: 跨平台桌面通知
  - `window_manager ^0.3.7`: 窗口管理和控制
  - `system_tray ^2.0.3`: 系统托盘功能

- 📦 **状态管理**
  - `provider ^6.1.1`: 响应式状态管理
  - `shared_preferences ^2.2.2`: 本地数据持久化

- 🔄 **数据处理**
  - `json_annotation ^4.8.1` & `json_serializable ^6.7.1`: JSON 序列化

## 🚀 快速开始

### 系统要求
- **macOS**: 10.14+ (Mojave 及更高版本)
- **Windows**: 10+ (1809 及更高版本)
- **Linux**: Ubuntu 18.04+ / 其他发行版
- **Flutter SDK**: 3.8.1+
- **Dart SDK**: 3.8.0+

### 🔧 开发环境搭建

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/gotify_client_flutter.git
   cd gotify_client_flutter
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成模型代码**
   ```bash
   dart run build_runner build
   ```

4. **运行应用**
   ```bash
   # macOS 桌面版
   flutter run -d macos
   
   # Windows 桌面版
   flutter run -d windows
   
   # Linux 桌面版
   flutter run -d linux
   ```

### 📦 构建发布版本

```bash
# 构建 macOS 应用
flutter build macos --release

# 构建 Windows 应用
flutter build windows --release

# 构建 Linux 应用
flutter build linux --release
```

构建完成后，可执行文件位于：
- **macOS**: `build/macos/Build/Products/Release/`
- **Windows**: `build/windows/runner/Release/`
- **Linux**: `build/linux/x64/release/bundle/`

## 📚 使用指南

### 🔧 初始设置

1. **启动应用**
   - 首次运行时，应用会显示连接状态卡片
   - 点击右上角的设置按钮 (⚙️) 进入配置页面

2. **配置 Gotify 服务器**
   ```
   服务器地址: https://gotify.yourdomain.com
   客户端令牌: C1234567890abcdef  (在 Gotify 管理面板中创建)
   ```

3. **高级选项**
   - ✅ **启用桌面通知**: 新消息到达时显示系统通知
   - ✅ **应用启动时自动连接**: 无需手动点击连接
   - ⏱️ **连接超时时间**: 默认 30 秒，可根据网络环境调整

### 🔌 连接到服务器

1. **保存设置**
   - 在设置页面配置完成后，点击「保存设置」
   - 系统会自动验证配置并保存

2. **建立连接**
   - 返回主界面，点击连接状态卡片中的连接按钮
   - 或使用「测试连接」功能验证配置

3. **状态指示**
   - 🟢 **已连接**: WebSocket 连接正常，可以接收消息
   - 🟡 **连接中**: 正在尝试建立连接
   - 🔴 **已断开**: 连接失败或中断

### 📬 消息管理

1. **接收通知**
   - 连接成功后，应用会自动接收来自 Gotify 的所有通知
   - 新消息会实时显示在主界面的消息列表中

2. **桌面通知**
   - 如果启用了桌面通知，系统会在新消息到达时弹出通知提醒
   - 点击通知可以快速跳转到应用

3. **消息详情**
   - 点击消息列表中的任意消息可查看详细信息
   - 包括消息标题、内容、优先级、时间等

### 🏠 系统托盘功能

1. **最小化到托盘**
   - 点击窗口右上角的关闭按钮 (❌) 时，应用不会退出
   - 窗口将隐藏到系统托盘，应用继续在后台运行

2. **托盘图标状态**
   - ✓ **已连接**: 显示勾号表示与 Gotify 服务器连接正常
   - ... **连接中**: 显示省略号表示正在连接
   - ↻ **重连中**: 显示循环箭头表示正在重连
   - ! **连接错误**: 显示感叹号表示连接出错

3. **托盘交互**
   - **单击托盘图标**: 切换窗口显示/隐藏状态
   - **右键托盘图标**: 显示上下文菜单
     - 显示窗口
     - 隐藏窗口  
     - 关于
     - 退出

4. **智能提示**
   - 悬停在托盘图标上显示当前连接状态
   - 显示消息数量（如果有未读消息）
   - 例如：`Gotify Client - 已连接 - 3 条消息`

### 🧪 测试功能

- 📬 **测试通知**: 验证桌面通知系统是否工作正常
- 🔌 **测试连接**: 验证服务器配置和网络连接
- 📊 **调试模式**: 在开发环境下显示详细的日志信息

## 🏢 项目架构

项目采用分层架构设计，结构清晰，易于维护和扩展：

```
lib/
├── main.dart                     # 🚀 应用入口点
├── models/                       # 📊 数据模型层
│   ├── app_config.dart          # 应用配置模型
│   ├── app_config.g.dart        # 自动生成的序列化代码
│   ├── connection_status.dart   # 连接状态枚举
│   ├── gotify_message.dart      # Gotify 消息模型
│   └── gotify_message.g.dart    # 自动生成的序列化代码
├── services/                     # 🔧 业务服务层
│   ├── app_state.dart           # 全局状态管理
│   ├── debug_logger.dart        # 调试日志服务
│   ├── gotify_service.dart      # Gotify API 服务
│   └── notification_service.dart # 桌面通知服务
├── pages/                        # 📱 界面页面
│   ├── home_page.dart           # 主页面 - 消息列表和状态
│   └── settings_page.dart       # 设置页面 - 配置管理
└── widgets/                      # 🧩 可复用组件
    ├── connection_status_card.dart # 连接状态卡片
    ├── debug_url_dialog.dart     # 调试 URL 对话框
    └── message_list_item.dart    # 消息列表项组件
```

### 📚 核心组件说明

- **`main.dart`**: 应用入口，负责初始化窗口管理器和根组件
- **`AppState`**: 使用 Provider 模式的全局状态管理，包含连接状态、消息列表等
- **`GotifyService`**: 封装 Gotify API 调用和 WebSocket 连接管理
- **`NotificationService`**: 跨平台桌面通知功能封装

## 🚀 技术亮点

### 🔄 实时通信架构
- **WebSocket 长连接**: 与 Gotify 服务器保持实时双向通信
- **智能重连机制**: 网络中断时指数退避算法自动重连
- **心跳检测**: 定期 Ping/Pong 保持连接活跃

### 🧠 状态管理模式
- **Provider 架构**: 响应式状态管理，自动 UI 更新
- **全局状态**: 集中式状态管理，防止数据失同
- **持久化存储**: 配置信息本地保存，下次启动直接恢复

### 🌐 跨平台支持
- **原生性能**: 使用 Flutter 原生编译，接近原生应用性能
- **一套代码**: 同一套代码运行在 macOS、Windows、Linux
- **系统集成**: 原生桌面通知、窗口管理等系统级功能

### 🔒 错误处理机制
- **分级错误处理**: 网络错误、认证错误、系统错误分别处理
- **用户友好提示**: 明确的错误信息和操作指引
- **自动恢复**: 可恢复错误自动重试，减少用户干预

## 🔍 故障排除指南

### 🔌 连接问题

**常见问题及解决方案：**

1. **服务器地址错误**
   - 检查 URL 格式：`https://gotify.example.com`
   - 确保不包含结尾斜杠
   - 验证 HTTPS/HTTP 协议正确

2. **客户端令牌问题**
   - 在 Gotify 管理界面的「客户端」页面创建新令牌
   - 确认令牌具有正确权限
   - 注意令牌大小写敏感

3. **网络连接问题**
   - 检查防火墙设置，允许应用访问网络
   - 验证 DNS 解析是否正常
   - 尝试在浏览器中访问 Gotify 服务器

### 📱 通知问题

**逐步检查清单：**

1. **系统权限**
   - **macOS**: 系统偏好设置 > 通知 > 允许应用发送通知
   - **Windows**: 设置 > 系统 > 通知 > 应用通知设置
   - **Linux**: 检查桌面环境的通知服务状态

2. **应用设置**
   - 确认「启用桌面通知」开关已打开
   - 使用「测试通知」功能验证

3. **系统级检查**
   - 检查是否在「勿扰模式」下
   - 验证系统音量设置

### 📊 性能问题

**优化建议：**

1. **内存使用**
   - 应用会自动清理过旧消息以节约内存
   - 可在设置中调整消息保存数量

2. **网络优化**
   - 调整连接超时时间适应网络环境
   - 在网络不稳定时关闭自动连接

## 🛠️ 开发说明

### 🤖 AI 辅助开发流程

> **特别说明**: 本项目采用人工智能辅助开发模式，结合 AI 代码生成和人工质量控制。

**AI 辅助开发的优势：**
- ⚡ 快速原型开发和功能迭代
- 🧠 智能代码生成和优化建议
- 📚 自动文档生成和代码注释
- 🔍 智能错误检测和修复建议
- 💯 代码质量和最佳实践保证

### 🔥 如何参与开发

1. **添加新功能**
   ```bash
   # 1. 创建功能分支
   git checkout -b feature/your-feature-name
   
   # 2. 在相应目录下创建新文件
   # 遵循项目的分层架构
   
   # 3. 更新状态管理类（如需要）
   # 4. 编写单元测试
   # 5. 运行测试确保功能正常
   flutter test
   ```

2. **代码生成和更新**
   ```bash
   # 修改带有 @JsonSerializable 注解的模型类后
   dart run build_runner build
   
   # 清理旧的生成文件
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **调试和测试**
   ```bash
   # 开发模式运行（启用调试日志）
   flutter run -d macos --debug
   
   # 运行单元测试
   flutter test
   
   # 运行集成测试
   flutter drive --target=test_driver/app.dart
   ```

### 📋 代码规范

- **命名规范**: 使用 Dart 官方命名规范
- **文件组织**: 按功能模块分层组织
- **注释规范**: 使用 Dart Doc 格式注释
- **代码格式**: 使用 `dart format` 自动格式化

### 📺 版本发布

1. **更新版本号**
   - 修改 `pubspec.yaml` 中的 `version` 字段
   - 遵循语义化版本规范 (SemVer)

2. **构建发布版本**
   ```bash
   # 清理构建缓存
   flutter clean
   flutter pub get
   
   # 构建各平台版本
   flutter build macos --release
   flutter build windows --release  
   flutter build linux --release
   ```

## 🤝 贡献指南

欢迎所有开发者参与项目贡献！

### 📝 提交 Issue
- 使用 Issue 模板描述问题
- 提供详细的重现步骤
- 附上相关的日志和截图

### 🔀 Pull Request
1. Fork 项目并创建特性分支
2. 完成功能开发和测试
3. 遵循代码规范和最佳实践
4. 提交 PR 并详细描述变更

### 📊 代码质量
- 单元测试覆盖率 > 80%
- 所有公共 API 必须有文档
- 遵循 Dart 官方代码风格

## 📜 许可证

本项目采用 [MIT 许可证](LICENSE)。

### 关于 AI 辅助开发
本项目使用人工智能技术辅助开发，但所有代码都经过人工审查、测试和优化。AI 仅作为开发工具使用，不影响代码的质量和安全性。

---

## 🔗 相关链接

- 🌐 [Gotify 官方网站](https://gotify.net/)
- 📚 [Flutter 开发文档](https://docs.flutter.dev/)
- 🏠 [Dart 语言指南](https://dart.dev/guides)
- 🧩 [Material Design 3](https://m3.material.io/)

**最后更新**: 2025-09-04  
**作者**: AI 辅助开发 + 人工审查优化  
**版本**: v1.0.0
