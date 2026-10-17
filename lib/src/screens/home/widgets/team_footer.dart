import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/theme.dart';

// ---------------------------------------------------------------------------
// TeamFooter — Sticky footer at the bottom of the Home page.
//
// Shows a "Meet The Team" button that navigates to /team (Person D's page).
// ---------------------------------------------------------------------------

class TeamFooter extends StatelessWidget {
  const TeamFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.l,
        horizontal: AppSpacing.m,
      ),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Made with ❤️ by the Canteen Crave team',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.m),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.team),
            icon: const Icon(Icons.group_outlined, size: 18),
            label: const Text('Meet The Team'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
      ),
    );
  }
}
