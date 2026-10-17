import 'package:flutter/material.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/theme.dart';
import '../../../models/category_model.dart';
import 'category_list_item.dart';

// ---------------------------------------------------------------------------
// CategoryPanel — Scrollable left panel listing all menu categories.
//
// Widths (HOME_CONTEXT.md Section 4):
//   • Mobile (<600)   : ~96px  (icon on top, name below)
//   • Tablet (600-1023): ~180px (icon + name side by side)
//   • Desktop (1024+) : ~240px
// ---------------------------------------------------------------------------

class CategoryPanel extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelectCategory;

  const CategoryPanel({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = screenSizeOf(context);
    final width = switch (screenSize) {
      ScreenSize.mobile  => 96.0,
      ScreenSize.tablet  => 180.0,
      ScreenSize.desktop => 240.0,
    };
    final isCompact = screenSize == ScreenSize.mobile;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.textMuted.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: categories.isEmpty
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.5,
                indent: AppSpacing.s,
                endIndent: AppSpacing.s,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat.id == selectedCategoryId;
                return CategoryListItem(
                  category: cat,
                  isSelected: isSelected,
                  isCompact: isCompact,
                  onTap: () => onSelectCategory(cat.id),
                );
              },
            ),
    );
  }
}
