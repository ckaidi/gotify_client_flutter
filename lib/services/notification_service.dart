import 'dart:developer';
import 'package:local_notifier/local_notifier.dart';
import '../models/gotify_message.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;
  bool _isEnabled = true;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await localNotifier.setup(
        appName: 'Gotify Client',
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
      _isInitialized = true;
      log('通知服务初始化成功');
    } catch (e) {
      log('通知服务初始化失败: $e');
      rethrow;
    }
  }

  Future<void> showNotification(GotifyMessage message) async {
    if (!_isInitialized || !_isEnabled) {
      log('通知服务未初始化或已禁用');
      return;
    }

    try {
      final notification = LocalNotification(
        title: message.title.isEmpty ? 'Gotify 通知' : message.title,
        body: message.message,
        identifier: 'gotify_${message.id}',
      );

      // 设置通知图标和操作
      notification.onClick = () {
        log('用户点击了通知: ${message.title}');
        // 这里可以添加点击通知后的操作，比如打开应用窗口
      };

      notification.onClose = (reason) {
        log('通知关闭: ${message.title}, 原因: $reason');
      };

      await notification.show();
      log('已显示通知: ${message.title}');

    } catch (e) {
      log('显示通知失败: $e');
    }
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    log('通知服务${enabled ? "已启用" : "已禁用"}');
  }

  bool get isEnabled => _isEnabled;

  Future<void> clearAllNotifications() async {
    try {
      // local_notifier 暂时不支持清除所有通知的功能
      // 这里可以记录已显示的通知ID，然后逐个关闭
      log('清除所有通知');
    } catch (e) {
      log('清除通知失败: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      // 在 Windows 和 macOS 上，通常不需要显式请求权限
      // 但我们可以尝试显示一个测试通知来验证权限
      final testNotification = LocalNotification(
        title: 'Gotify Client',
        body: '通知权限测试',
        identifier: 'permission_test',
      );
      
      await testNotification.show();
      
      // 延迟一秒后关闭测试通知
      Future.delayed(const Duration(seconds: 1), () async {
        await testNotification.close();
      });
      
      return true;
    } catch (e) {
      log('请求通知权限失败: $e');
      return false;
    }
  }

  void dispose() {
    _isEnabled = false;
    log('通知服务已销毁');
  }
}