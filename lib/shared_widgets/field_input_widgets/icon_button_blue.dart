import 'package:flutter/material.dart';

class IconButtonBlue extends StatelessWidget {
  const IconButtonBlue({
    super.key,
    required this.icon,
    required this.label,
    required this.routeName,
    this.arguments,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final dynamic arguments;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        Navigator.pushNamed(
          context,
          routeName,
          arguments: arguments,
        );
      },
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}