// lib/utils/logger.dart
import 'package:logging/logging.dart';

class AppLogger {
  static final _logger = Logger('AppLogger');
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    _initialized = true;
    Logger.root.level = Level.ALL; // 모든 로그 레벨을 표시
    Logger.root.onRecord.listen((record) {
      print(
          '[${record.time}] [${record.level.name}] ${record.loggerName}: ${record.message}');
    });
    _log('INFO', 'Logger initialized');
  }

  static void debug(String message) {
    _logger.fine(message);
  }

  static void info(String message) {
    _logger.info(message);
  }

  static void warning(String message) {
    _logger.warning(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.shout(message, error, stackTrace);
  }

  static void _log(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('[$level] $timestamp: $message');
  }
}
