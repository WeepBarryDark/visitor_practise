import 'package:flutter/material.dart';

class BackgroundImageLevel extends StatelessWidget {
  const BackgroundImageLevel({
    super.key,
    required this.CustomBackgroundUrl,
    required this.mainWidget,
  });

  final CustomBackgroundUrl;
  final mainWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: 
          BoxDecoration(
            image: DecorationImage(image: NetworkImage(CustomBackgroundUrl),
            fit: BoxFit.cover,
            opacity: 0.9,
            ),
          ),
          child: mainWidget,
      ),
    );
  }
}