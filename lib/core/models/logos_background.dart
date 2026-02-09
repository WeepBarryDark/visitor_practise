import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LogosBackground {
  // Top Logo properties
  final String currentTopLogUrl;
  final Uint8List? bytesTopLog;

  // Top Logo properties
  final String currentBottomLogUrl;
  final Uint8List? bytesBottomLog;

  // Background properties
  final String currentBackground;
  final Uint8List? bytesBackground;

  // Private constructor
  LogosBackground({
    required this.currentTopLogUrl,
    required this.bytesTopLog,
    required this.currentBottomLogUrl,
    required this.bytesBottomLog,
    required this.currentBackground,
    required this.bytesBackground,
  });

}
