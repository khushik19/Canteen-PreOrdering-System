import 'package:flutter/material.dart';

import 'package:canteen_crave/src/core/theme/theme.dart';

// ---------------------------------------------------------------------------
// SplashScreen — shown briefly while the app checks if the user is already
// logged in (AuthStatus.unknown).
//
// This prevents a flash of the login page for returning users.
// Once AuthController resolves to authenticated or unauthenticated,
// the router redirects away from this screen automatically.
// ---------------------------------------------------------------------------

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.l),

            // App name
            Text('Canteen Crave', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.l),

            // Loading spinner
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
