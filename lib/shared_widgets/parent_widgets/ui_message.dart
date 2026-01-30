enum UiMessageType {
  success,
  error,
  warning,
}

class UiMessage {
  final String text;
  final UiMessageType type;

  const UiMessage({
    required this.text,
    required this.type,
  });
}