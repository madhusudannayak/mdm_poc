import 'package:flutter/material.dart';

/// Centered progress indicator with an optional caption.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
