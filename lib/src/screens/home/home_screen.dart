import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:canteen_crave/src/app/routes/app_routes.dart';
import 'package:canteen_crave/src/core/theme/theme.dart';
import 'package:canteen_crave/src/core/utils/auth_guard.dart';
import 'package:canteen_crave/src/screens/auth/auth_controller.dart';

// ---------------------------------------------------------------------------
// HomeScreen — Home screen for students and guests.
//
// Guest Mode details (from GUEST_MODE_CONTEXT.md Section 2.5):
//   • Top bar campus indicator with "Browsing as guest" chip (disappears on login)
//   • Top bar action:
//       - Guests see a "Log in" button (icon + text on laptop, icon only on phone)
//       - Logged-in users see the profile avatar -> /profile
//   • Guest-guarded actions: calls requireLogin() when tapping actions
//     that need an account (favourite, checkout).
// ---------------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch AuthController to update UI when auth state changes.
    final auth = context.watch<AuthController>();
    final isWideScreen = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: AppSpacing.m,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campus indicator
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PIMR UG',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: AppSpacing.xs),
                Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ],
            ),

            // Guest hint chip (only shown when browsing as guest)
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
            // On wide screens (laptop): icon + text "Log in"
            if (isWideScreen)
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
              // On phones: icon-only button with tooltip
              IconButton(
                icon: const Icon(Icons.login_rounded),
                tooltip: 'Log in',
                color: AppColors.primary,
                onPressed: () => context.go(AppRoutes.login),
              ),
          ] else ...[
            // Logged-in user: profile avatar -> /profile
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Profile',
              color: AppColors.textDark,
              onPressed: () => context.go(AppRoutes.profile),
            ),
            // Quick sign out for testing
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign out',
              color: AppColors.textMuted,
              onPressed: () => auth.signOut(),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      auth.isGuest
                          ? Icons.explore_outlined
                          : Icons.restaurant_menu_rounded,
                      size: 54,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      auth.isGuest ? 'Guest Exploration' : 'Welcome to Canteen Crave',
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      auth.isGuest
                          ? 'You are browsing without an account. Try adding to cart freely, or test an account-required action below.'
                          : 'Signed in as ${auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name : auth.currentUser?.email ?? 'Student'}.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // Test requireLogin: Heart / Favourite item
                    OutlinedButton.icon(
                      onPressed: () async {
                        final allowed = await requireLogin(
                          context,
                          message: 'Log in to save items to your favourites.',
                        );
                        if (!context.mounted) return;
                        if (allowed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to favourites!')),
                          );
                        }
                      },
                      icon: const Icon(Icons.favorite_border_rounded, size: 20),
                      label: const Text('Favourite an item (Test Login Guard)'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Test requireLogin: Place order / Checkout
                    ElevatedButton.icon(
                      onPressed: () async {
                        final allowed = await requireLogin(
                          context,
                          message: 'Log in to place your order.',
                        );
                        if (!context.mounted) return;
                        if (allowed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Proceeding to payment!')),
                          );
                        }
                      },
                      icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                      label: const Text('Checkout / Place Order (Test Login Guard)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
