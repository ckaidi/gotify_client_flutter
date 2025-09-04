import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';
import '../models/gotify_message.dart';
import '../models/connection_status.dart';
import 'gotify_service.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal() {
    _initialize();
  }

  final GotifyService _gotifyService = GotifyService();
  final NotificationService _notificationService = NotificationService();
  
  AppConfig _config = const AppConfig();
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  final List<GotifyMessage> _messages = [];
  String? _lastError;
  
  late StreamSubscription _statusSubscription;
  late StreamSubscription _messageSubscription;
  late StreamSubscription _errorSubscription;

  // Getters
  AppConfig get config => _config;
  ConnectionStatus get connectionStatus => _connectionStatus;
  List<GotifyMessage> get messages => List.unmodifiable(_messages);
  String? get lastError => _lastError;
  bool get isConnected => _connectionStatus.isConnected;
  bool get canConnect => _connectionStatus.canConnect && _config.isValid;

  void _initialize() {
    // 监听Gotify服务的状态变化
    _statusSubscription = _gotifyService.statusStream.listen((status) {
      _connectionStatus = status;
      _lastError = null; // 清除错误状态
      
      notifyListeners();
    });

    // 监听新消息
    _messageSubscription = _gotifyService.messageStream.listen((message) {
      _messages.insert(0, message); // 新消息插入到列表顶部
      
      // 限制消息列表长度
      if (_messages.length > 100) {
        _messages.removeRange(100, _messages.length);
      }
      
      // 显示桌面通知
      if (_config.enableNotifications) {
        _notificationService.showNotification(message);
      }
      
      notifyListeners();
    });

    // 监听错误
    _errorSubscription = _gotifyService.errorStream.listen((error) {
      _lastError = error;
      notifyListeners();
    });

    // 初始化通知服务
    _initializeNotificationService();
    
    // 加载保存的配置
    _loadConfig();
  }

  Future<void> _initializeNotificationService() async {
    try {
      await _notificationService.initialize();
      log('通知服务初始化成功');
    } catch (e) {
      log('通知服务初始化失败: $e');
    }
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 直接从SharedPreferences读取各个配置项
      final serverUrl = prefs.getString('server_url') ?? '';
      final clientToken = prefs.getString('client_token') ?? '';
      final enableNotifications = prefs.getBool('enable_notifications') ?? true;
      final autoConnect = prefs.getBool('auto_connect') ?? false;
      final connectionTimeoutSeconds = prefs.getInt('connection_timeout_seconds') ?? 30;

      _config = AppConfig(
        serverUrl: serverUrl,
        clientToken: clientToken,
        enableNotifications: enableNotifications,
        autoConnect: autoConnect,
        connectionTimeoutSeconds: connectionTimeoutSeconds,
      );

      _notificationService.setEnabled(_config.enableNotifications);
      
      log('配置加载成功: serverUrl=${serverUrl.isNotEmpty ? "已设置" : "未设置"}, token=${clientToken.isNotEmpty ? "已设置" : "未设置"}');
      notifyListeners();

      // 如果设置了自动连接且配置有效，则尝试连接
      if (_config.autoConnect && _config.isValid) {
        await connect();
      }
    } catch (e) {
      log('加载配置失败: $e');
    }
  }

  Future<void> updateConfig(AppConfig newConfig) async {
    _config = newConfig;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_url', newConfig.serverUrl);
      await prefs.setString('client_token', newConfig.clientToken);
      await prefs.setBool('enable_notifications', newConfig.enableNotifications);
      await prefs.setBool('auto_connect', newConfig.autoConnect);
      await prefs.setInt('connection_timeout_seconds', newConfig.connectionTimeoutSeconds);
      
      // 更新通知服务状态
      _notificationService.setEnabled(newConfig.enableNotifications);
      
      log('配置保存成功: serverUrl=${newConfig.serverUrl.isNotEmpty ? "已设置(${newConfig.serverUrl})" : "未设置"}, token=${newConfig.clientToken.isNotEmpty ? "已设置" : "未设置"}');
      notifyListeners();
    } catch (e) {
      log('保存配置失败: $e');
      _lastError = '保存配置失败: $e';
      notifyListeners();
    }
  }

  Future<void> connect() async {
    if (!_config.isValid) {
      _lastError = '配置无效：请先设置服务器地址和客户端令牌';
      notifyListeners();
      return;
    }

    _lastError = null;
    notifyListeners();
    
    await _gotifyService.connect(_config);
  }

  void disconnect() {
    _gotifyService.disconnect();
    _lastError = null;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  Future<void> testNotification() async {
    if (!_config.enableNotifications) {
      _lastError = '通知已禁用';
      notifyListeners();
      return;
    }

    final testMessage = GotifyMessage(
      id: 0,
      title: '测试通知',
      message: '这是一条测试通知消息',
      date: DateTime.now(),
      priority: 5,
      appid: 0,
    );

    await _notificationService.showNotification(testMessage);
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    _messageSubscription.cancel();
    _errorSubscription.cancel();
    _gotifyService.dispose();
    _notificationService.dispose();
    super.dispose();
  }
}