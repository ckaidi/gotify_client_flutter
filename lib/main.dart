import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'services/app_state.dart';
import 'services/system_tray_service.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化窗口管理器（桌面端）
  await windowManager.ensureInitialized();
  
  await windowManager.setPreventClose(true);
  
  // 设置窗口选项
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(600, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Gotify Client',
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    debugPrint("🔒 窗口初始化完成，防止关闭已启用");
  });
  
  // 初始化系统托盘（如果支持）
  if (SystemTrayService.isSystemTraySupported()) {
    debugPrint("系统托盘支持，开始初始化...");
    try {
      await SystemTrayService().initSystemTray();
      debugPrint("系统托盘初始化成功");
    } catch (e) {
      debugPrint("系统托盘初始化失败: $e");
    }
  } else {
    debugPrint("系统托盘不支持");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    // 延迟注册窗口事件监听，确保窗口已准备好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("注册窗口事件监听器");
      windowManager.addListener(this);
    });
  }

  @override
  void dispose() {
    // 移除窗口事件监听
    windowManager.removeListener(this);
    super.dispose();
  }
  
  @override
  void onWindowClose() async {
    debugPrint("🔒 窗口关闭事件触发，隐藏到托盘");
    // 检查是否阻止关闭
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      try {
        // 隐藏窗口到托盘
        await windowManager.hide();
        debugPrint("✅ 窗口已隐藏到托盘");
      } catch (e) {
        debugPrint("❌ 隐藏窗口失败: $e");
      }
    }
  }
  
  @override
  void onWindowEvent(String eventName) {
    debugPrint("🔔 窗口事件: $eventName");
    super.onWindowEvent(eventName);
  }
  
  @override
  void onWindowFocus() {
    debugPrint("🔍 窗口获得焦点");
    super.onWindowFocus();
  }
  
  @override
  void onWindowBlur() {
    debugPrint("🔍 窗口失去焦点");
    super.onWindowBlur();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Gotify Client',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomePage(),
        routes: {
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}
