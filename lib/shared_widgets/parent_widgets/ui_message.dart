import 'package:flutter/material.dart';

enum UiMessageType {
  success,
  error,
  warning,
  info,
}

class UiMessage {
  final String text;
  final UiMessageType type;
  final Duration? duration;
  final SnackBarAction? action;

  const UiMessage({
    required this.text,
    required this.type,
    this.duration,
    this.action,
  });

  /// Get the background color for this message type
  Color get backgroundColor {
    switch (type) {
      case UiMessageType.success:
        return Colors.green;
      case UiMessageType.error:
        return Colors.red;
      case UiMessageType.warning:
        return Colors.orange;
      case UiMessageType.info:
        return Colors.blue;
    }
  }

  /// Get the icon for this message type
  IconData get icon {
    switch (type) {
      case UiMessageType.success:
        return Icons.check_circle;
      case UiMessageType.error:
        return Icons.error;
      case UiMessageType.warning:
        return Icons.warning;
      case UiMessageType.info:
        return Icons.info;
    }
  }

  /// Show this message as a SnackBar
  void show(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 2),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Factory constructors for common message types
  factory UiMessage.success(String text, {Duration? duration, SnackBarAction? action}) {
    return UiMessage(
      text: text,
      type: UiMessageType.success,
      duration: duration,
      action: action,
    );
  }

  factory UiMessage.error(String text, {Duration? duration, SnackBarAction? action}) {
    return UiMessage(
      text: text,
      type: UiMessageType.error,
      duration: duration,
      action: action,
    );
  }

  factory UiMessage.warning(String text, {Duration? duration, SnackBarAction? action}) {
    return UiMessage(
      text: text,
      type: UiMessageType.warning,
      duration: duration,
      action: action,
    );
  }

  factory UiMessage.info(String text, {Duration? duration, SnackBarAction? action}) {
    return UiMessage(
      text: text,
      type: UiMessageType.info,
      duration: duration,
      action: action,
    );
  }
}

/// Extension methods for BuildContext to show messages more easily
extension UiMessageExtension on BuildContext {
  void showMessage(UiMessage message) {
    message.show(this);
  }

  void showSuccess(String text, {Duration? duration}) {
    UiMessage.success(text, duration: duration).show(this);
  }

  void showError(String text, {Duration? duration}) {
    UiMessage.error(text, duration: duration).show(this);
  }

  void showWarning(String text, {Duration? duration}) {
    UiMessage.warning(text, duration: duration).show(this);
  }

  void showInfo(String text, {Duration? duration}) {
    UiMessage.info(text, duration: duration).show(this);
  }
}