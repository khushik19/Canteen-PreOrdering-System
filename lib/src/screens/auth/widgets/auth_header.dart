import 'package:flutter/material.dart';

import 'package:canteen_crave/src/core/theme/theme.dart';

// ---------------------------------------------------------------------------
// AuthHeader — the logo + title + tagline shown at the top of auth screens.
//
// Used on: Sign In, Forgot Password.
// Sign Up has its own header (back arrow + "Create your account").
// ---------------------------------------------------------------------------

class AuthHeader extends StatelessWidget {
  /// Optional tagline below the title. Defaults to the main tagline.
  final String tagline;

  const AuthHeader({
    super.key,
    this.tagline = 'Order ahead. Skip the queue.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),

        // Logo: food icon inside a circular orange-tinted container.
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: AppSpacing.m),

        // App name
        Text('Canteen Crave', style: AppTextStyles.title),

        const SizedBox(height: AppSpacing.xs),

        // Tagline
        Text(
          tagline,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

