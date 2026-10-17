import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/theme.dart';
import '../../../models/menu_item_model.dart';
import 'bestseller_card.dart';

// ---------------------------------------------------------------------------
// BestsellerCarousel — Horizontal scrolling row of BestsellerCards.
//
// Specs from HOME_CONTEXT.md Section 9:
//   • Card width ~170 on phones, ~220 on laptop.
//   • On tablet/desktop, show left + right arrow buttons so mouse users
//     can scroll (RULES.md Section 5.7, laptop must have arrow buttons).
//   • Mouse drag already enabled globally via AppScrollBehavior.
//   • Tapping a card navigates to /menu?category=<categoryId>.
// ---------------------------------------------------------------------------

class BestsellerCarousel extends StatefulWidget {
  final List<MenuItemModel> items;

  const BestsellerCarousel({super.key, required this.items});

  @override
  State<BestsellerCarousel> createState() => _BestsellerCarouselState();
}

class _BestsellerCarouselState extends State<BestsellerCarousel> {
  final _scrollCtrl = ScrollController();

  // How far to scroll per arrow button tap.
  static const double _scrollStep = 250;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    _scrollCtrl.animateTo(
      (_scrollCtrl.offset - _scrollStep).clamp(
        _scrollCtrl.position.minScrollExtent,
        _scrollCtrl.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollCtrl.animateTo(
      (_scrollCtrl.offset + _scrollStep).clamp(
        _scrollCtrl.position.minScrollExtent,
        _scrollCtrl.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Card width adapts to screen size.
    final screenSize = screenSizeOf(context);
    final cardWidth = screenSize == ScreenSize.mobile ? 170.0 : 220.0;
    final showArrows = screenSize != ScreenSize.mobile;

    final listView = SizedBox(
      // Card height = image height (cardWidth × 3/4) + body (~90px).
      height: cardWidth * 0.75 + 90,
      child: ListView.separated(
        controller: _scrollCtrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        itemCount: widget.items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.m),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return SizedBox(
            width: cardWidth,
            child: BestsellerCard(
              item: item,
              onTap: () =>
                  context.go('/menu?category=${item.categoryId}'),
            ),
          );
        },
      ),
    );

    if (!showArrows) return listView;

    // Tablet / Desktop: wrap the list with arrow buttons on each side.
    return Row(
      children: [
        // Left arrow
        Tooltip(
          message: 'Scroll left',
          child: IconButton(
            onPressed: _scrollLeft,
            icon: const Icon(Icons.chevron_left_rounded),
            iconSize: 32,
            style: IconButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size(48, 48),
            ),
          ),
        ),

        // Scrollable list takes the remaining space.
        Expanded(child: listView),

        // Right arrow
        Tooltip(
          message: 'Scroll right',
          child: IconButton(
            onPressed: _scrollRight,
            icon: const Icon(Icons.chevron_right_rounded),
            iconSize: 32,
            style: IconButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
      ],
    );
  }
}
