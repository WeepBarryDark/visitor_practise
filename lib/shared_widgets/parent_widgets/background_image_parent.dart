import 'package:flutter/material.dart';

class BackgroundImageParent extends StatelessWidget {
  const BackgroundImageParent({
    super.key,
    required this.customBackgroundUrl,
    required this.mainWidget,
    this.appBar,
  });

  final String customBackgroundUrl;
  final Widget mainWidget;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: 
          BoxDecoration(
            image: DecorationImage(image: NetworkImage(customBackgroundUrl),
            fit: BoxFit.cover,
            opacity: 0.9,
            ),
          ),
          child: mainWidget,
      ),
    );
  }
}