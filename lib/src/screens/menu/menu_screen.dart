import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/layout/centered_content.dart';
import '../../core/state/campus_controller.dart';
import '../../core/theme/theme.dart';
import '../shared/campus_app_bar.dart';
import '../shared/state_views.dart';
import 'menu_page_controller.dart';
import 'widgets/category_panel.dart';
import 'widgets/menu_item_card.dart';
import 'widgets/menu_item_tile.dart';

// ---------------------------------------------------------------------------
// MenuScreen — The two-panel canteen menu browser.
//
// Layout:
//   • Top: Shared CampusAppBar + Category title heading.
//   • Left: Scrollable CategoryPanel (responsive width: 96 / 180 / 240).
//   • Right: Item area with independent scroll (ListView on phone, GridView on tablet/desktop).
//
// Query parameter & Tab switching:
//   Because StatefulShellRoute preserves tab state, didUpdateWidget listens
//   to changes in [initialCategoryId] and calls selectCategory, ensuring
//   Home -> Category -> Menu works every time.
// ---------------------------------------------------------------------------

class MenuScreen extends StatefulWidget {
  final String? initialCategoryId;

  const MenuScreen({super.key, this.initialCategoryId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ScrollController _itemScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final campus = context.read<CampusController>().campusId;
      final menuCtrl = context.read<MenuPageController>();
      if (widget.initialCategoryId != null) {
        menuCtrl.init(campus, initialCategoryId: widget.initialCategoryId);
      } else if (menuCtrl.categories.isEmpty) {
        menuCtrl.init(campus);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When navigated from Home with a category query param
    if (widget.initialCategoryId != null) {
      final menuCtrl = context.read<MenuPageController>();
      if (widget.initialCategoryId != oldWidget.initialCategoryId ||
          menuCtrl.selectedCategoryId != widget.initialCategoryId) {
        menuCtrl.selectCategory(widget.initialCategoryId!);
        _scrollToTop();
      }
    }
  }

  @override
  void dispose() {
    _itemScrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_itemScrollCtrl.hasClients) {
      _itemScrollCtrl.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuCtrl = context.watch<MenuPageController>();
    final campusName = context.watch<CampusController>().campusName;
    final screenSize = screenSizeOf(context);
    final isMobile = screenSize == ScreenSize.mobile;

    final selectedCategoryName = menuCtrl.selectedCategory?.name ?? 'Menu';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CampusAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Sub-header: category name + count
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textMuted.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    selectedCategoryName,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  if (!menuCtrl.isLoading && menuCtrl.errorMessage == null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        '${menuCtrl.items.length} items',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Two-panel body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left panel: Categories
                  CategoryPanel(
                    categories: menuCtrl.categories,
                    selectedCategoryId: menuCtrl.selectedCategoryId,
                    onSelectCategory: (id) {
                      menuCtrl.selectCategory(id);
                      _scrollToTop();
                    },
                  ),

                  // Right panel: Food Items
                  Expanded(
                    child: CenteredContent(
                      child: _buildItemArea(
                        context,
                        menuCtrl: menuCtrl,
                        campusName: campusName,
                        isMobile: isMobile,
                        screenSize: screenSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemArea(
    BuildContext context, {
    required MenuPageController menuCtrl,
    required String campusName,
    required bool isMobile,
    required ScreenSize screenSize,
  }) {
    if (menuCtrl.isLoading) {
      return isMobile
          ? const LoadingView(count: 6, height: 110)
          : const GridLoadingView(count: 6);
    }

    if (menuCtrl.errorMessage != null) {
      return ErrorView(
        message: menuCtrl.errorMessage!,
        onRetry: () => menuCtrl.retry(),
      );
    }

    if (menuCtrl.items.isEmpty) {
      return EmptyView(
        message:
            'Nothing in this category on $campusName yet. Try another category.',
      );
    }

    if (isMobile) {
      return ListView.builder(
        controller: _itemScrollCtrl,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s,
          horizontal: AppSpacing.xs,
        ),
        itemCount: menuCtrl.items.length,
        itemBuilder: (context, index) {
          final item = menuCtrl.items[index];
          return MenuItemTile(item: item);
        },
      );
    }

    // Tablet: 2 columns, Desktop: 3 columns
    final crossAxisCount = screenSize == ScreenSize.tablet ? 2 : 3;

    return GridView.builder(
      controller: _itemScrollCtrl,
      padding: const EdgeInsets.all(AppSpacing.m),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.m,
        crossAxisSpacing: AppSpacing.m,
        childAspectRatio: 0.72,
      ),
      itemCount: menuCtrl.items.length,
      itemBuilder: (context, index) {
        final item = menuCtrl.items[index];
        return MenuItemCard(item: item);
      },
    );
  }
}
