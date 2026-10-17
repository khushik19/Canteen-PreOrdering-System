import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/theme.dart';
import '../../../models/category_model.dart';
import 'category_tile.dart';

// ---------------------------------------------------------------------------
// CategoryGrid — Responsive grid of category tiles on the Home page.
//
// Columns by screen size (HOME_CONTEXT.md Section 9):
//   • Mobile  (<600)  : 3 columns  (3×3 for 9 categories)
//   • Tablet  (600+)  : 4 columns
//   • Desktop (1024+) : 6 columns
//
// Tapping a tile navigates to /menu?category=<categoryId>.
// ---------------------------------------------------------------------------

class CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final screenSize = screenSizeOf(context);

    // Column counts per breakpoint
    final crossAxisCount = switch (screenSize) {
      ScreenSize.mobile  => 3,
      ScreenSize.tablet  => 4,
      ScreenSize.desktop => 6,
    };

    return GridView.builder(
      // Let the parent CustomScrollView handle scrolling.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.m,
        crossAxisSpacing: AppSpacing.m,
        // Slightly taller than square to give space for the text label below.
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return CategoryTile(
          category: cat,
          onTap: () => context.go('/menu?category=${cat.id}'),
        );
      },
    );
  }
}
