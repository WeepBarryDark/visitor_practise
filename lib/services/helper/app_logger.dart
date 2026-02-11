import 'package:flutter/foundation.dart';

/// Centralized logging service for the application
/// Provides different log levels and consistent formatting
class AppLogger {
  AppLogger._();

  static const String _prefix = '[VisitorApp]';

  /// Debug level - development only
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix 🐛 $tagStr $message');
    }
  }

  /// Info level - general information
  static void info(String message, [String? tag]) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix ℹ️ $tagStr $message');
  }

  /// Warning level - potential issues
  static void warning(String message, [String? tag]) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix ⚠️ $tagStr $message');
  }

  /// Error level - errors that occurred
  static void error(String message, [dynamic error, StackTrace? stackTrace, String? tag]) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix ❌ $tagStr $message');

    if (error != null) {
      debugPrint('$_prefix ❌ Error details: $error');
    }

    if (stackTrace != null && kDebugMode) {
      debugPrint('$_prefix ❌ Stack trace:\n$stackTrace');
    }
  }

  /// Success level - successful operations
  static void success(String message, [String? tag]) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix ✅ $tagStr $message');
  }

  /// Network level - API calls and responses
  static void network(String message, {String? method, String? endpoint, int? statusCode}) {
    final methodStr = method != null ? '$method ' : '';
    final endpointStr = endpoint ?? '';
    final statusStr = statusCode != null ? ' [$statusCode]' : '';
    debugPrint('$_prefix 🌐 $methodStr$endpointStr$statusStr - $message');
  }
}
