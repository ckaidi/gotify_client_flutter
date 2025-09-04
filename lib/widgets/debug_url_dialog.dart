import 'package:flutter/material.dart';
import '../models/app_config.dart';

class DebugUrlDialog extends StatefulWidget {
  const DebugUrlDialog({super.key});

  @override
  State<DebugUrlDialog> createState() => _DebugUrlDialogState();
}

class _DebugUrlDialogState extends State<DebugUrlDialog> {
  final _controller = TextEditingController();
  String? _websocketUrl;
  String? _cleanUrl;
  bool? _isValid;

  void _testUrl() {
    final config = AppConfig(serverUrl: _controller.text, clientToken: 'test');
    setState(() {
      _websocketUrl = config.websocketUrl;
      _cleanUrl = config.cleanServerUrl;
      _isValid = config.isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('URL 调试工具'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '测试URL',
                hintText: 'http://8.134.222.127:96/#/',
              ),
              onChanged: (_) => _testUrl(),
            ),
            const SizedBox(height: 16),
            if (_cleanUrl != null) ...[
              _buildInfoRow('清理后的URL', _cleanUrl!),
              _buildInfoRow('WebSocket URL', _websocketUrl!),
              _buildInfoRow('URL有效性', _isValid! ? '有效' : '无效'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}