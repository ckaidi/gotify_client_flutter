// 这是一个简单的测试脚本来验证URL解析
import 'package:flutter/widgets.dart';

import 'lib/models/app_config.dart';

void main() {
  debugPrint('开始URL解析测试...');
  
  // 测试您的服务器地址
  final config = AppConfig(
    serverUrl: 'http://8.134.222.127:96/#/',
    clientToken: 'test-token',
  );
  
  debugPrint('原始URL: ${config.serverUrl}');
  debugPrint('清理后URL: ${config.cleanServerUrl}');
  debugPrint('WebSocket URL: ${config.websocketUrl}');
  debugPrint('配置有效性: ${config.isValid}');
  
  // 测试其他常见格式
  final testUrls = [
    'http://8.134.222.127:96',
    'http://8.134.222.127:96/',
    'http://8.134.222.127:96/#',
    'http://8.134.222.127:96/#/',
    'https://gotify.example.com',
    'https://gotify.example.com:443',
  ];
  
  debugPrint('\n=== 多种URL格式测试 ===');
  for (final url in testUrls) {
    final testConfig = AppConfig(serverUrl: url, clientToken: 'test');
    debugPrint('URL: $url');
    debugPrint('  -> 清理后: ${testConfig.cleanServerUrl}');
    debugPrint('  -> WebSocket: ${testConfig.websocketUrl}');
    debugPrint('  -> 有效性: ${testConfig.isValid}');
    debugPrint('');
  }
}