import 'package:json_annotation/json_annotation.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig {
  final String serverUrl;
  final String clientToken;
  final bool enableNotifications;
  final bool autoConnect;
  final int connectionTimeoutSeconds;

  const AppConfig({
    this.serverUrl = '',
    this.clientToken = '',
    this.enableNotifications = true,
    this.autoConnect = false,
    this.connectionTimeoutSeconds = 30,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  AppConfig copyWith({
    String? serverUrl,
    String? clientToken,
    bool? enableNotifications,
    bool? autoConnect,
    int? connectionTimeoutSeconds,
  }) {
    return AppConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      clientToken: clientToken ?? this.clientToken,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoConnect: autoConnect ?? this.autoConnect,
      connectionTimeoutSeconds: connectionTimeoutSeconds ?? this.connectionTimeoutSeconds,
    );
  }

  bool get isValid {
    if (serverUrl.isEmpty || clientToken.isEmpty) return false;
    
    try {
      final cleanUrl = cleanServerUrl;
      final uri = Uri.parse(cleanUrl);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  String get websocketUrl {
    if (serverUrl.isEmpty) return '';
    
    // 清理URL，移除末尾的路径部分
    String cleanUrl = serverUrl.trim();
    if (cleanUrl.endsWith('/#/') || cleanUrl.endsWith('/#')) {
      cleanUrl = cleanUrl.replaceAll(RegExp(r'/#/?$'), '');
    }
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    
    try {
      final uri = Uri.parse(cleanUrl);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      
      // 处理端口号
      String portPart = '';
      if (uri.hasPort && uri.port != (uri.scheme == 'https' ? 443 : 80)) {
        portPart = ':${uri.port}';
      }
      
      // Gotify的WebSocket端点是 /stream
      // 根据Gotify官方文档：https://gotify.net/docs/pushmsg
      return '$scheme://${uri.host}$portPart/stream';
    } catch (e) {
      return '';
    }
  }
  
  String get cleanServerUrl {
    if (serverUrl.isEmpty) return '';
    
    String cleanUrl = serverUrl.trim();
    if (cleanUrl.endsWith('/#/') || cleanUrl.endsWith('/#')) {
      cleanUrl = cleanUrl.replaceAll(RegExp(r'/#/?$'), '');
    }
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    
    return cleanUrl;
  }
  
  // 获取多个可能的WebSocket URL进行尝试
  List<String> get possibleWebsocketUrls {
    if (serverUrl.isEmpty) return [];
    
    final baseUrl = _getBaseWebSocketUrl();
    if (baseUrl.isEmpty) return [];
    
    // 常见的Gotify WebSocket端点
    return [
      '$baseUrl/stream',     // 标准端点
      '$baseUrl/ws',         // 替代端点
      '$baseUrl/websocket',  // 另一个可能的端点
    ];
  }
  
  String _getBaseWebSocketUrl() {
    if (serverUrl.isEmpty) return '';
    
    // 清理URL，移除末尾的路径部分
    String cleanUrl = serverUrl.trim();
    if (cleanUrl.endsWith('/#/') || cleanUrl.endsWith('/#')) {
      cleanUrl = cleanUrl.replaceAll(RegExp(r'/#/?$'), '');
    }
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    
    try {
      final uri = Uri.parse(cleanUrl);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      
      // 处理端口号
      String portPart = '';
      if (uri.hasPort && uri.port != (uri.scheme == 'https' ? 443 : 80)) {
        portPart = ':${uri.port}';
      }
      
      return '$scheme://${uri.host}$portPart';
    } catch (e) {
      return '';
    }
  }
}