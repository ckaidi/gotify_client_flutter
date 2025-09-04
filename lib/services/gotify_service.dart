import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/gotify_message.dart';
import '../models/app_config.dart';
import '../models/connection_status.dart';
import 'debug_logger.dart';

class GotifyService {
  static final GotifyService _instance = GotifyService._internal();
  factory GotifyService() => _instance;
  GotifyService._internal();

  final DebugLogger _logger = DebugLogger();
  WebSocketChannel? _channel;
  AppConfig? _config;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _heartbeatInterval = const Duration(seconds: 30);

  // 状态流控制器
  final StreamController<ConnectionStatus> _statusController = 
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<GotifyMessage> _messageController = 
      StreamController<GotifyMessage>.broadcast();
  final StreamController<String> _errorController = 
      StreamController<String>.broadcast();

  // 公开流
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  Stream<GotifyMessage> get messageStream => _messageController.stream;
  Stream<String> get errorStream => _errorController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  ConnectionStatus get currentStatus => _currentStatus;

  void _updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      _logger.log('状态更新: ${status.displayName}');
    }
  }

  Future<void> connect(AppConfig config) async {
    _logger.log('开始连接进程...');
    _logger.log('服务器地址: ${config.serverUrl}');
    _logger.log('清理后的服务器地址: ${config.cleanServerUrl}');
    _logger.log('配置有效性: ${config.isValid}');
    
    if (!config.isValid) {
      final errorMsg = '配置无效：服务器地址和客户端令牌不能为空';
      _logger.log(errorMsg, level: LogLevel.error);
      _emitError(errorMsg);
      return;
    }

    _config = config;
    _logger.log('WebSocket URL: ${_config!.websocketUrl}');
    _updateStatus(ConnectionStatus.connecting);

    try {
      await _establishConnection();
    } catch (e) {
      _logger.log('连接异常: $e', level: LogLevel.error);
      _handleConnectionError(e.toString());
    }
  }

  Future<void> _establishConnection() async {
    if (_config == null) {
      log('错误: _config 为 null');
      return;
    }

    try {
      // 先测试HTTP连接
      await _testHttpConnection();
      
      final websocketUrl = _config!.websocketUrl;
      log('生成的 WebSocket URL: $websocketUrl');
      
      if (websocketUrl.isEmpty) {
        throw Exception('无法生成WebSocket URL，请检查服务器地址格式');
      }
      
      final uri = Uri.parse('$websocketUrl?token=${_config!.clientToken}');
      log('最终连接地址: $uri');
      
      // 检查URL的有效性
      if (!uri.hasScheme || !uri.hasAuthority) {
        throw Exception('无效的服务器地址格式: $uri');
      }

      log('开始创建WebSocket连接...');
      
      // 设置连接超时
      _channel = WebSocketChannel.connect(
        uri,
        protocols: null,
      );
      
      log('WebSocket对象已创建，等待连接...');
      
      // 设置连接超时定时器
      Timer? timeoutTimer = Timer(Duration(seconds: _config!.connectionTimeoutSeconds), () {
        log('连接超时，当前状态: $_currentStatus');
        if (_currentStatus == ConnectionStatus.connecting) {
          _channel?.sink.close();
          _handleConnectionError('连接超时，请检查网络和服务器地址');
        }
      });
      
      // 监听连接状态
      _channel!.ready.then((_) {
        timeoutTimer?.cancel(); // 取消超时定时器
        log('WebSocket连接已建立成功!');
        _updateStatus(ConnectionStatus.connected);
        _resetReconnectAttempts();
        _startHeartbeat();
        
        // 监听消息
        _channel!.stream.listen(
          (data) {
            log('收到数据: $data');
            _onMessage(data);
          },
          onError: (error) {
            timeoutTimer?.cancel();
            log('WebSocket流错误: $error');
            _onError(error);
          },
          onDone: () {
            timeoutTimer?.cancel();
            log('WebSocket流已关闭');
            _onDisconnected();
          },
        );
      }).catchError((error) {
        timeoutTimer?.cancel();
        log('WebSocket连接失败: $error');
        log('错误类型: ${error.runtimeType}');
        
        String errorMessage = '连接失败: $error';
        
        // 根据错误类型提供更友好的错误信息
        final errorStr = error.toString().toLowerCase();
        if (errorStr.contains('connection refused') || 
            errorStr.contains('econnrefused')) {
          errorMessage = '连接被拒绝，请检查服务器地址和端口是否正确';
        } else if (errorStr.contains('timeout') || 
                   errorStr.contains('etimedout')) {
          errorMessage = '连接超时，请检查网络连接和防火墙设置';
        } else if (errorStr.contains('host not found') || 
                   errorStr.contains('enotfound')) {
          errorMessage = '无法找到服务器，请检查服务器地址是否正确';
        } else if (errorStr.contains('401') || 
                   errorStr.contains('unauthorized')) {
          errorMessage = '身份验证失败，请检查客户端令牌是否正确';
        } else if (errorStr.contains('websocketexception') || 
                   errorStr.contains('handshake')) {
          errorMessage = 'WebSocket握手失败，请检查服务器是否支持WebSocket';
        }
        
        _handleConnectionError(errorMessage);
      });

    } catch (e) {
      log('建立连接时发生异常: $e');
      log('异常类型: ${e.runtimeType}');
      
      String errorMessage = '连接失败: $e';
      
      if (e.toString().contains('无法生成WebSocket URL') || 
          e.toString().contains('无效的服务器地址格式')) {
        errorMessage = e.toString();
      }
      
      _handleConnectionError(errorMessage);
    }
  }
  
  Future<void> _testHttpConnection() async {
    if (_config == null) return;
    
    try {
      final cleanUrl = _config!.cleanServerUrl;
      log('测试HTTP连接到: $cleanUrl');
      
      final uri = Uri.parse('$cleanUrl/health');
      log('测试健康检查端点: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Gotify-Flutter-Client/1.0',
        },
      ).timeout(Duration(seconds: 10));
      
      log('HTTP响应状态码: ${response.statusCode}');
      log('HTTP响应内容: ${response.body}');
      
      if (response.statusCode == 200) {
        log('HTTP连接测试成功');
      } else {
        log('HTTP连接测试返回非200状态码');
      }
      
    } catch (e) {
      log('HTTP连接测试失败: $e');
      // 不抛出异常，继续尝试WebSocket连接
    }
  }

  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(data);
      
      // 检查是否是心跳响应
      if (jsonData.containsKey('type') && jsonData['type'] == 'pong') {
        log('收到心跳响应');
        return;
      }

      // 解析Gotify消息
      final message = GotifyMessage.fromJson(jsonData);
      log('收到新消息: ${message.title}');
      _messageController.add(message);
      
    } catch (e) {
      log('解析消息失败: $e, 原始数据: $data');
      _emitError('解析消息失败: $e');
    }
  }

  void _onError(error) {
    log('WebSocket错误: $error');
    _handleConnectionError(error.toString());
  }

  void _onDisconnected() {
    log('WebSocket连接已断开');
    _stopHeartbeat();
    
    if (_currentStatus == ConnectionStatus.connected) {
      // 意外断开，尝试重连
      _attemptReconnect();
    } else {
      _updateStatus(ConnectionStatus.disconnected);
    }
  }

  void _handleConnectionError(String error) {
    _updateStatus(ConnectionStatus.error);
    _emitError(error);
    _stopHeartbeat();
    
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _attemptReconnect();
    } else {
      _emitError('重连次数已达上限，请检查网络连接和配置');
      _updateStatus(ConnectionStatus.disconnected);
    }
  }

  void _attemptReconnect() {
    if (_config == null) return;
    
    _reconnectAttempts++;
    _updateStatus(ConnectionStatus.reconnecting);
    
    final delay = Duration(seconds: _reconnectAttempts * 2);
    log('将在 ${delay.inSeconds} 秒后尝试第 $_reconnectAttempts 次重连');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_config != null) {
        _establishConnection();
      }
    });
  }

  void _resetReconnectAttempts() {
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_channel != null && _currentStatus == ConnectionStatus.connected) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
          log('发送心跳');
        } catch (e) {
          log('发送心跳失败: $e');
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _emitError(String error) {
    _errorController.add(error);
    log('错误: $error');
  }

  void disconnect() {
    log('主动断开连接');
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _resetReconnectAttempts();
    
    _channel?.sink.close();
    _channel = null;
    _config = null;
    
    _updateStatus(ConnectionStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _messageController.close();
    _errorController.close();
  }
}