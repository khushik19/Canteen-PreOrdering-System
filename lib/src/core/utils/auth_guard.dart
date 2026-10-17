import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:canteen_crave/src/app/routes/app_routes.dart';
import 'package:canteen_crave/src/core/theme/theme.dart';
import 'package:canteen_crave/src/screens/auth/auth_controller.dart';

// ---------------------------------------------------------------------------
// AuthGuard — reusable helper to prompt guests to log in.
//
// Usage:
//   if (!await requireLogin(context, message: 'Log in to place your order.')) return;
//
// If the user is logged in, this returns true immediately.
// If the user is a guest, it shows a friendly "Log in to continue" modal sheet
// with buttons to log in, create an account, or dismiss ("Maybe later"),
// and returns false.
// ---------------------------------------------------------------------------

/// Returns `true` if the user is authenticated and allowed to continue.
/// If exploring as a guest (or unauthenticated), displays the "Log in to continue"
/// sheet and returns `false`.
Future<bool> requireLogin(
  BuildContext context, {
  String? message,
}) async {
  final auth = context.read<AuthController>();

  // If already logged in, continue with the requested action.
  if (auth.isLoggedIn) {
    return true;
  }

  // Otherwise, prompt the guest with a bottom sheet modal.
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Center(
        child: ConstrainedBox(
          // Maximum width of 480 ensures nice layout on web / laptops.
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.card),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.m,
              AppSpacing.l,
              AppSpacing.l,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subtle drag indicator handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Sheet title
                  Text(
                    'Log in to continue',
                    style: AppTextStyles.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s),

                  // Friendly explanation message
                  Text(
                    message ?? 'You need an account to do this.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Primary button: Log In
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        context.go(AppRoutes.login);
                      },
                      child: const Text('Log in'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),

                  // Secondary button: Create account
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        context.go(AppRoutes.signup);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadius.button,
                          ),
                        ),
                        textStyle: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      child: const Text('Create account'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Text button: Maybe later
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(
                      'Maybe later',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  return false;
}
