import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

// ---------------------------------------------------------------------------
// CookingTimeChip — Displays estimated prep time, e.g. "⏱ 10 min".
//
// Crucial for students planning their pickup time between classes.
// Includes a Semantics label for screen readers.
// ---------------------------------------------------------------------------

class CookingTimeChip extends StatelessWidget {
  final int minutes;
  final bool compact;

  const CookingTimeChip({
    super.key,
    required this.minutes,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$minutes minutes estimated preparation time',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.xs : AppSpacing.s,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: AppColors.textMuted.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 13,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              '$minutes min',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
