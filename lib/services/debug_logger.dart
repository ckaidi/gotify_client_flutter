import 'dart:collection';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class DebugLogger extends ChangeNotifier {
  static final DebugLogger _instance = DebugLogger._internal();
  factory DebugLogger() => _instance;
  DebugLogger._internal();

  final Queue<LogEntry> _logs = Queue<LogEntry>();
  final int maxLogs = 100;

  List<LogEntry> get logs => _logs.toList();

  void log(String message, {LogLevel level = LogLevel.info}) {
    final entry = LogEntry(
      message: message,
      level: level,
      timestamp: DateTime.now(),
    );

    _logs.addFirst(entry);
    
    // 限制日志数量
    while (_logs.length > maxLogs) {
      _logs.removeLast();
    }

    // 输出到控制台
    developer.log(message, name: 'GotifyClient');
    
    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

extension LogLevelExtension on LogLevel {
  String get displayName {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}