import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/connection_status.dart';
import '../services/app_state.dart';

class ConnectionStatusCard extends StatelessWidget {
  const ConnectionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  _buildStatusIcon(appState.connectionStatus),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '连接状态',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getStatusColor(appState.connectionStatus),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(appState.connectionStatus).withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appState.connectionStatus.displayName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: _getStatusColor(appState.connectionStatus),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        if (appState.config.serverUrl.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appState.config.cleanServerUrl,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(context, appState),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(ConnectionStatus status) {
    IconData iconData;
    Color color;
    Color backgroundColor;

    switch (status) {
      case ConnectionStatus.connected:
        iconData = Icons.wifi;
        color = Colors.green.shade700;
        backgroundColor = Colors.green.shade100;
        break;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        iconData = Icons.wifi_find;
        color = Colors.orange.shade700;
        backgroundColor = Colors.orange.shade100;
        break;
      case ConnectionStatus.error:
        iconData = Icons.wifi_off;
        color = Colors.red.shade700;
        backgroundColor = Colors.red.shade100;
        break;
      case ConnectionStatus.disconnected:
        iconData = Icons.wifi_off;
        color = Colors.grey.shade600;
        backgroundColor = Colors.grey.shade100;
        break;
    }

    Widget iconWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );

    // 为连接中状态添加旋转动画
    if (status == ConnectionStatus.connecting || status == ConnectionStatus.reconnecting) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 6.28, // 2π
            child: iconWidget,
          );
        },
      );
    }

    return iconWidget;
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  Widget _buildActionButton(BuildContext context, AppState appState) {
    if (appState.connectionStatus == ConnectionStatus.connecting ||
        appState.connectionStatus == ConnectionStatus.reconnecting) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.orange.shade600,
          ),
        ),
      );
    }

    IconData iconData;
    Color color;
    Color backgroundColor;
    String tooltip;
    VoidCallback? onPressed;

    if (appState.isConnected) {
      iconData = Icons.stop_rounded;
      color = Colors.red.shade700;
      backgroundColor = Colors.red.shade50;
      tooltip = '断开连接';
      onPressed = appState.disconnect;
    } else if (appState.canConnect) {
      iconData = Icons.play_arrow_rounded;
      color = Colors.green.shade700;
      backgroundColor = Colors.green.shade50;
      tooltip = '连接';
      onPressed = appState.connect;
    } else {
      iconData = Icons.settings_rounded;
      color = Colors.blue.shade700;
      backgroundColor = Colors.blue.shade50;
      tooltip = '前往设置';
      onPressed = () {
        Navigator.pushNamed(context, '/settings');
      };
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          iconData,
          color: color,
          size: 20,
        ),
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}