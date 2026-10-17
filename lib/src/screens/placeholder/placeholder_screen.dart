import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

// ---------------------------------------------------------------------------
// PlaceholderScreen — Friendly "Coming soon" placeholder for screens
// assigned to teammates (Persons B, C, D) or upcoming features.
// ---------------------------------------------------------------------------

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? owner;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.owner,
    this.icon = Icons.construction_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      title,
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      subtitle ?? 'This feature is currently under active development.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    if (owner != null) ...[
                      const SizedBox(height: AppSpacing.m),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          'Owner: $owner',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
