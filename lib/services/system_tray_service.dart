import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

/// 系统托盘服务
/// 提供系统托盘图标和菜单功能
class SystemTrayService  with TrayListener  {
  static final SystemTrayService _instance = SystemTrayService._internal();
  factory SystemTrayService() => _instance;
  SystemTrayService._internal();

  bool _isInitialized = false;

  /// 初始化系统托盘
  Future<void> initSystemTray() async {
    if (_isInitialized) {
      return;
    }
    try {
      trayManager.addListener(this);

      // 设置托盘图标路径
      String iconPath;
      if (Platform.isWindows) {
        iconPath = 'assets/app.ico';
      } else if (Platform.isMacOS) {
        iconPath = 'assets/icons/app_icon.png';
      } else {
        iconPath = 'assets/icons/app_icon.png';
      }
      await trayManager.setIcon(iconPath);

      // 创建托盘菜单
      Menu menu = Menu(
        items: [
          MenuItem(key: 'show_window', label: '显示窗口'),
          MenuItem(key: 'hide_window', label: '隐藏窗口'),
          MenuItem.separator(),
          MenuItem(key: 'exit_app', label: '退出'),
        ],
      );

      // 设置托盘菜单=
      await trayManager.setContextMenu(menu);

      _isInitialized = true;
    } catch (e) {
      // 即使初始化失败，也将_isInitialized设置为true，以避免重复尝试初始化
      _isInitialized = true;
    }
  }

  // 托盘图标双击事件
  @override
  void onTrayIconMouseDown() async {
    debugPrint("🖱️ 托盘图标被点击，显示窗口");
    await _showWindow();
  }

  // 托盘图标右键点击事件
  @override
  void onTrayIconRightMouseDown() async {
    debugPrint("🖱️ 托盘图标右键点击，显示菜单");
    await trayManager.popUpContextMenu();
  }

  // 托盘菜单项点击事件
  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    debugPrint("📋 托盘菜单项点击: ${menuItem.key}");
    switch (menuItem.key) {
      case 'show_window':
        await _showWindow();
        break;
      case 'hide_window':
        await _hideWindow();
        break;
      case 'exit_app':
        await _quitApp();
        break;
      default:
        break;
    }
  }

  /// 显示窗口
  Future<void> _showWindow() async {
    try {
      debugPrint("📱 正在显示窗口...");
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setSkipTaskbar(false);
      debugPrint("✅ 窗口已显示并获得焦点");
    } catch (e) {
      debugPrint("❌ 显示窗口失败: $e");
    }
  }  
  
  Future<void> destroySystemTray() async {
    if (!_isInitialized) {
      return;
    }

    try {
      // 移除托盘监听器
      trayManager.removeListener(this);

      // 销毁托盘图标
      await trayManager.destroy();
    } catch (e) {
      debugPrint('$e');
    } finally {
      // 无论是否成功，都将_isInitialized设置为false
      _isInitialized = false;
    }
  }

  /// 退出应用
  Future<void> _quitApp() async {
    await destroySystemTray();
    try {
      await windowManager.destroy();
    } catch (e) {
      debugPrint("退出应用失败: $e");
    }

    // 最后使用dart:io中的exit方法退出应用
    exit(0);
  }

  /// 隐藏窗口
  Future<void> _hideWindow() async {
    try {
      debugPrint("🙈 正在隐藏窗口...");
      await windowManager.hide();
      debugPrint("✅ 窗口已隐藏到托盘");
    } catch (e) {
      debugPrint("❌ 隐藏窗口失败: $e");
    }
  }

  /// 检查系统托盘是否可用
  static bool isSystemTraySupported() {
    // 在桌面平台上通常都支持系统托盘
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }
}