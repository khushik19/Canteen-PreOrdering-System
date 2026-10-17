import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../models/category_model.dart';
import '../../shared/food_image.dart';

// ---------------------------------------------------------------------------
// CategoryTile — One tappable tile in the Home category grid.
//
// Shows a square image (placeholder icon) with the category name below.
// Tapping calls onTap() — the parent will navigate to /menu?category=<id>.
// ---------------------------------------------------------------------------

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: category.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Square image area (1:1 aspect ratio).
            Expanded(
              child: FoodImage(
                imageUrl: category.imageUrl,
                aspectRatio: 1,
                borderRadius: AppRadius.card,
                semanticLabel: category.name,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Category name — always shown as text, never truncated.
            Text(
              category.name,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
