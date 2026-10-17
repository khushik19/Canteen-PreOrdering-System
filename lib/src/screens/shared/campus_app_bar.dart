import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/theme.dart';
import '../auth/auth_controller.dart';
import 'campus_dropdown.dart';

// ---------------------------------------------------------------------------
// CampusAppBar — Top app bar shared by Home and Menu screens.
//
// Left:
//   - CampusDropdown (active campus selection)
//   - "Browsing as guest" chip (visible only when in guest mode)
// Right:
//   - If guest: "Log in" button (text+icon on wide screen, icon-only on phone)
//   - If logged in: Profile button -> /profile and quick sign out
// ---------------------------------------------------------------------------

class CampusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CampusAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final screenSize = screenSizeOf(context);
    final isWide = screenSize != ScreenSize.mobile;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleSpacing: AppSpacing.m,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campus picker
          const CampusDropdown(),

          // Guest mode chip
          if (auth.isGuest) ...[
            const SizedBox(width: AppSpacing.s),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Browsing as guest',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (auth.isGuest) ...[
          // Guest action: Log in button
          if (isWide)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.m),
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.login),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Log in'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.login_rounded),
              tooltip: 'Log in',
              color: AppColors.primary,
              onPressed: () => context.go(AppRoutes.login),
            ),
        ] else ...[
          // Logged-in actions: Profile avatar -> /profile
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            color: AppColors.textDark,
            onPressed: () => context.go(AppRoutes.profile),
          ),
          // Sign out button
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            color: AppColors.textMuted,
            onPressed: () => auth.signOut(),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}
