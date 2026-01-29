import 'package:flutter/material.dart';

class BackgroundImageParent extends StatelessWidget {
  const BackgroundImageParent({
    super.key,
    required this.webNotAsset,
    required this.customBackgroundUrl,
    required this.mainWidget,
    this.appBar,
  });

  final bool webNotAsset;
  final String customBackgroundUrl;
  final Widget mainWidget;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration:BoxDecoration(
          image: DecorationImage(
            image: webNotAsset
                ? NetworkImage(customBackgroundUrl)
                : AssetImage(customBackgroundUrl),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: mainWidget,
      ),
    );
  }
}