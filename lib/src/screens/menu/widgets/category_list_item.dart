import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../models/category_model.dart';
import '../../shared/food_image.dart';

// ---------------------------------------------------------------------------
// CategoryListItem — Single item in the left category navigation panel.
//
// Highlights selection with:
//   1. Active left indicator bar (visible marker, doesn't rely on color alone).
//   2. Accent background tint.
//   3. Bold primary-colored text.
//
// Layout adapts based on [isCompact] (mobile):
//   • Compact: stacked vertically (image on top, name below, 2-line max).
//   • Wide: side-by-side (image on left, name on right).
// ---------------------------------------------------------------------------

class CategoryListItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: category.name,
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Row(
              children: [
                // Active indicator pill on the left edge (3.5px width)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 4,
                  height: isCompact ? 36 : 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),

                // Content area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 6 : AppSpacing.s,
                      vertical: AppSpacing.s,
                    ),
                    child: isCompact ? _buildCompactContent() : _buildWideContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: FoodImage(
            imageUrl: category.imageUrl,
            aspectRatio: 1,
            borderRadius: AppRadius.card,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          category.name,
          style: AppTextStyles.caption.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildWideContent() {
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: FoodImage(
            imageUrl: category.imageUrl,
            aspectRatio: 1,
            borderRadius: AppRadius.card,
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            category.name,
            style: (isSelected ? AppTextStyles.bodyBold : AppTextStyles.body)
                .copyWith(
              color: isSelected ? AppColors.primary : AppColors.textDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
