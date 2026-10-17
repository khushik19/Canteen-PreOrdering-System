import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/layout/centered_content.dart';
import '../../core/theme/theme.dart';

// ---------------------------------------------------------------------------
// AppShell — Responsive frame around the main 4 student tabs:
//   0: Home (/home)
//   1: Menu (/menu)
//   2: Favs (/favs)
//   3: Cart (/cart)
//
// Rules from RULES.md & HOME_CONTEXT.md Section 7:
//   • Mobile (<600): Scaffold with bottom NavigationBar (labels always shown).
//   • Tablet (600-1023): NavigationRail on the left (compact with icons + labels).
//   • Desktop (1024+): Extended NavigationRail (wide with icon + label on one row).
//   • CenteredContent (max width 1200) wraps the page content.
//   • StatefulNavigationShell preserves each tab's scroll position when switching.
// ---------------------------------------------------------------------------

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    // If tapping the already active tab, reset it to its initial route.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = screenSizeOf(context);

    // Mobile layout: Bottom navigation bar
    if (screenSize == ScreenSize.mobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: CenteredContent(
            child: navigationShell,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
              tooltip: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu_rounded, color: AppColors.primary),
              label: 'Menu',
              tooltip: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.primary),
              label: 'Favs',
              tooltip: 'Favourites',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
              label: 'Cart',
              tooltip: 'Cart',
            ),
          ],
        ),
      );
    }

    // Tablet & Desktop layout: Side Navigation Rail
    final isDesktop = screenSize == ScreenSize.desktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          NavigationRail(
            extended: isDesktop,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primary.withValues(alpha: 0.15),
            labelType: isDesktop ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.m,
                horizontal: AppSpacing.s,
              ),
              child: isDesktop
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          'Canteen Crave',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu_rounded, color: AppColors.primary),
                label: Text('Menu'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border_rounded),
                selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.primary),
                label: Text('Favs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
                label: Text('Cart'),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: AppColors.textMuted.withValues(alpha: 0.15),
          ),
          Expanded(
            child: CenteredContent(
              child: navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}
