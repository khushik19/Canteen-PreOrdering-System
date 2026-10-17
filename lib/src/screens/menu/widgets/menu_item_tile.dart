import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/menu_item_model.dart';
import '../../shared/food_image.dart';
import 'cooking_time_chip.dart';
import 'veg_marker.dart';

// ---------------------------------------------------------------------------
// MenuItemTile — Row-based layout for mobile screens (<600px).
//
// Layout:
//   [FoodImage 96x96]  |  [VegMarker] [Name]
//                      |  [Description 2 lines max]
//                      |  [₹Price] [⏱ min] | [Add Button (min 48h)]
//
// If isAvailable == false:
//   • Faded opacity (0.55).
//   • Prominent "Unavailable" chip / badge.
//   • "Add" button is disabled.
// ---------------------------------------------------------------------------

class MenuItemTile extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onAddToCart;

  const MenuItemTile({
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
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xs,
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Food photo
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: FoodImage(
                          imageUrl: item.imageUrl,
                          aspectRatio: 1,
                          borderRadius: AppRadius.card,
                          semanticLabel: item.name,
                        ),
                      ),
                      if (!isAvailable)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: AppColors.error.withValues(alpha: 0.85),
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              'Unavailable',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),

                // 2. Info area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Veg marker + item name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: VegMarker(isVeg: item.isVeg, size: 13),
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
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),

                      // Price + Cooking time + Add button
                      Row(
                        children: [
                          Text(
                            priceStr,
                            style: AppTextStyles.bodyBold.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          CookingTimeChip(
                            minutes: item.cookingTimeMinutes,
                            compact: true,
                          ),
                          const Spacer(),
                          // Add button (min 48px height touch target)
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 48,
                              minWidth: 70,
                            ),
                            child: ElevatedButton(
                              onPressed: isAvailable
                                  ? () => _handleAdd(context)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s,
                                  vertical: AppSpacing.xs,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                ),
                              ),
                              child: const Text('Add'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
