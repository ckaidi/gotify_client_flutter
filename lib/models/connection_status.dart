enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
  reconnecting,
}

extension ConnectionStatusExtension on ConnectionStatus {
  String get displayName {
    switch (this) {
      case ConnectionStatus.disconnected:
        return '已断开连接';
      case ConnectionStatus.connecting:
        return '连接中...';
      case ConnectionStatus.connected:
        return '已连接';
      case ConnectionStatus.error:
        return '连接错误';
      case ConnectionStatus.reconnecting:
        return '重连中...';
    }
  }

  bool get isConnected => this == ConnectionStatus.connected;
  bool get canConnect => this == ConnectionStatus.disconnected || this == ConnectionStatus.error;
}