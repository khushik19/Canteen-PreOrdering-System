import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

// ---------------------------------------------------------------------------
// VegMarker — Green/Red square symbol indicating vegetarian or non-vegetarian.
//
// Complies with Indian food labeling standards (FSSAI) and accessibility rules:
//   • Square outer border with an inner filled circle.
//   • Green for Vegetarian, Red/Brown for Non-Vegetarian.
//   • Includes Semantics label "Vegetarian" or "Non-vegetarian".
//   • Optional text label beside it for high readability.
// ---------------------------------------------------------------------------

class VegMarker extends StatelessWidget {
  final bool isVeg;
  final bool showLabel;
  final double size;

  const VegMarker({
    super.key,
    required this.isVeg,
    this.showLabel = false,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppColors.success : AppColors.error;
    final label = isVeg ? 'Vegetarian' : 'Non-vegetarian';

    final symbol = Semantics(
      label: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.center,
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );

    if (!showLabel) return symbol;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        symbol,
        const SizedBox(width: AppSpacing.xs),
        Text(
          isVeg ? 'Veg' : 'Non-veg',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
