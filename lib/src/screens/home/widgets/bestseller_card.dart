import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/menu_item_model.dart';
import '../../shared/food_image.dart';

// ---------------------------------------------------------------------------
// BestsellerCard — One card in the horizontal bestsellers carousel.
//
// Shows:
//   • Food image (placeholder if no URL)
//   • Veg / non-veg dot with semantic label
//   • Item name (max 2 lines)
//   • Price in ₹
//   • Cooking time chip ("10 min")
//
// Width is NOT fixed here — the parent carousel controls it so the card
// adapts to mobile (170px) and desktop (220px).
// ---------------------------------------------------------------------------

class BestsellerCard extends StatelessWidget {
  final MenuItemModel item;

  /// Called when the user taps the card.
  final VoidCallback onTap;

  const BestsellerCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.name}, ${AppFormatters.formatRupees(item.price)}, '
          '${item.cookingTimeMinutes} minutes, '
          '${item.isVeg ? "Vegetarian" : "Non-vegetarian"}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food image (fixed 4:3 aspect ratio — no layout jump).
              FoodImage(
                imageUrl: item.imageUrl,
                aspectRatio: 4 / 3,
                borderRadius: 0, // card's own clip handles corners
                semanticLabel: item.name,
              ),

              // Card body
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg / non-veg dot row
                    Row(
                      children: [
                        Semantics(
                          label: item.isVeg ? 'Vegetarian' : 'Non-vegetarian',
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.isVeg
                                  ? AppColors.success
                                  : AppColors.error,
                              border: Border.all(
                                color: item.isVeg
                                    ? AppColors.success
                                    : AppColors.error,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          item.isVeg ? 'Veg' : 'Non-veg',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Item name (wraps to 2 lines max)
                    Text(
                      item.name,
                      style: AppTextStyles.bodyBold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Price + cooking time chip on one row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppFormatters.formatRupees(item.price),
                          style: AppTextStyles.bodyBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        _CookingChip(minutes: item.cookingTimeMinutes),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small "10 min" chip used inside the card.
class _CookingChip extends StatelessWidget {
  final int minutes;
  const _CookingChip({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$minutes minutes cooking time',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 12, color: AppColors.primary),
            const SizedBox(width: 2),
            Text(
              '$minutes min',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
