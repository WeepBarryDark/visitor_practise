import 'dart:typed_data';
import 'package:flutter/material.dart';

class BackgroundImageParent extends StatelessWidget {
  const BackgroundImageParent({
    super.key,
    required this.backgroundBytes,
    required this.mainWidget,
    this.appBar,
  });

  final Uint8List backgroundBytes;
  final Widget mainWidget;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(backgroundBytes),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: mainWidget,
      ),
    );
  }
}