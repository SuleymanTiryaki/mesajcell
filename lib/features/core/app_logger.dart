import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Uygulama geneli loglama — sadece debug modda çalışır
final class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    filter: _DebugFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: ConsoleOutput(),
  );

  /// Debug: genel bilgi
  static void d(dynamic message) => _logger.d(message);

  /// Info: akış adımları
  static void i(dynamic message) => _logger.i(message);

  /// Warning: beklenmeyen ama kırıcı olmayan durumlar
  static void w(dynamic message) => _logger.w(message);

  /// Error: hatalar
  static void e(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

class _DebugFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => kDebugMode;
}
