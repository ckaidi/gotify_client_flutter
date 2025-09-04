// 这是一个简单的测试脚本来验证URL解析
import 'lib/models/app_config.dart';

void main() {
  print('开始URL解析测试...');
  
  // 测试您的服务器地址
  final config = AppConfig(
    serverUrl: 'http://8.134.222.127:96/#/',
    clientToken: 'test-token',
  );
  
  print('原始URL: ${config.serverUrl}');
  print('清理后URL: ${config.cleanServerUrl}');
  print('WebSocket URL: ${config.websocketUrl}');
  print('配置有效性: ${config.isValid}');
  
  // 测试其他常见格式
  final testUrls = [
    'http://8.134.222.127:96',
    'http://8.134.222.127:96/',
    'http://8.134.222.127:96/#',
    'http://8.134.222.127:96/#/',
    'https://gotify.example.com',
    'https://gotify.example.com:443',
  ];
  
  print('\n=== 多种URL格式测试 ===');
  for (final url in testUrls) {
    final testConfig = AppConfig(serverUrl: url, clientToken: 'test');
    print('URL: $url');
    print('  -> 清理后: ${testConfig.cleanServerUrl}');
    print('  -> WebSocket: ${testConfig.websocketUrl}');
    print('  -> 有效性: ${testConfig.isValid}');
    print('');
  }
}