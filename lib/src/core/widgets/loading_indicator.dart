import 'package:flutter/material.dart';

/// Standard loading spinner — use this instead of a bare
/// CircularProgressIndicator so styling stays consistent app-wide.
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: TextStyle(color: theme.hintColor)),
          ],
        ],
      ),
    );
  }
}