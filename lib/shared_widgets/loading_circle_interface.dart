import 'package:flutter/material.dart';

class LoadingCircleInterface extends StatelessWidget {
  const LoadingCircleInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            )
          ],
        ),
      ),
    );
  }
}