import 'package:flutter/material.dart';
import 'package:canteen_crave/src/core/theme/theme.dart';

// ---------------------------------------------------------------------------
// TeamScreen — PLACEHOLDER
//
// This is a temporary screen so the router compiles. It will be replaced
// with the real implementation in a later task.
// ---------------------------------------------------------------------------

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Meet the Team',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
