import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/menu_item_model.dart';
import '../../shared/food_image.dart';
import 'cooking_time_chip.dart';
import 'veg_marker.dart';

// ---------------------------------------------------------------------------
// MenuItemCard — Card-based layout for tablet & desktop grids.
//
// Displayed in a 2-column (tablet) or 3-column (desktop) grid.
//
// Elements:
//   • Top food image (4:3 aspect ratio).
//   • Veg marker + Name + Description.
//   • Price + Cooking chip.
//   • Full-width Add button (minimum 48px height touch target).
//   • Unavailable state: dimmed opacity, "Unavailable" banner, disabled button.
// ---------------------------------------------------------------------------

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onAddToCart;

  const MenuItemCard({
    super.key,
    required this.item,
    this.onAddToCart,
  });

  void _handleAdd(BuildContext context) {
    if (!item.isAvailable) return;
    if (onAddToCart != null) {
      onAddToCart!();
    } else {
      // TODO(personB): call cart add here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} added! Cart is coming soon.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = item.isAvailable;
    final priceStr = AppFormatters.formatRupees(item.price);
    final vegText = item.isVeg ? 'vegetarian' : 'non-vegetarian';

    return Semantics(
      label: '${item.name}, $priceStr, $vegText, ready in ${item.cookingTimeMinutes} minutes'
          '${isAvailable ? "" : ", currently unavailable"}',
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.6,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Food image
              Stack(
                children: [
                  FoodImage(
                    imageUrl: item.imageUrl,
                    aspectRatio: 16 / 9,
                    borderRadius: 0,
                    semanticLabel: item.name,
                  ),
                  if (!isAvailable)
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          'Unavailable',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // 2. Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Veg marker + Name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: VegMarker(isVeg: item.isVeg, size: 14),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTextStyles.bodyBold,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Description
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const Spacer(),

                      // Price + Cooking chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            priceStr,
                            style: AppTextStyles.bodyBold.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          CookingTimeChip(minutes: item.cookingTimeMinutes),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s),

                      // Add button (min 48px height)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isAvailable
                              ? () => _handleAdd(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.button),
                            ),
                          ),
                          child: const Text('Add to Order'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
