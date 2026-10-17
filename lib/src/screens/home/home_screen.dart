import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/campus_controller.dart';
import '../../core/theme/theme.dart';
import '../../screens/shared/campus_app_bar.dart';
import '../../screens/shared/state_views.dart';
import 'home_controller.dart';
import 'widgets/bestseller_carousel.dart';
import 'widgets/category_grid.dart';
import 'widgets/team_footer.dart';

// ---------------------------------------------------------------------------
// HomeScreen — The main landing page for students and guests.
//
// Layout (single CustomScrollView = one lazy scroll, no nested-scroll issues):
//   1. CampusAppBar (SliverAppBar — campus dropdown + profile/login action)
//   2. "Bestsellers" section title
//   3. BestsellerCarousel (or loading/empty/error state)
//   4. "Categories" section title
//   5. CategoryGrid (or loading/empty/error state)
//   6. TeamFooter
//
// Data is loaded by HomeController, which auto-reloads via
// ChangeNotifierProxyProvider whenever the campus changes.
// ---------------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.select rebuilds only when campusId changes — not on every
    // CampusController notify (avoids over-rebuilds).
    final campusId = context.select<CampusController, String>(
      (c) => c.campusId,
    );

    // Watch HomeController to rebuild when loading/error/data changes.
    final ctrl = context.watch<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ------------------------------------------------------------------
          // 1. Top bar — campus picker + profile/login action
          // ------------------------------------------------------------------
          const SliverAppBar(
            floating: true,
            snap: true,
            forceElevated: false,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              // CampusAppBar is a PreferredSizeWidget that handles its own
              // layout; we embed it here inside the flexible space.
              collapseMode: CollapseMode.none,
              background: CampusAppBar(),
            ),
            toolbarHeight: kToolbarHeight,
          ),

          // ------------------------------------------------------------------
          // 2. "Bestsellers" section title
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.l,
                AppSpacing.m,
                AppSpacing.s,
              ),
              child: Text('Bestsellers', style: AppTextStyles.titleSmall),
            ),
          ),

          // ------------------------------------------------------------------
          // 3. Bestsellers carousel (with loading / empty / error states)
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: _BestsellerSection(ctrl: ctrl, campusId: campusId),
          ),

          // ------------------------------------------------------------------
          // 4. "Categories" section title
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.l,
                AppSpacing.m,
                AppSpacing.s,
              ),
              child: Text('Categories', style: AppTextStyles.titleSmall),
            ),
          ),

          // ------------------------------------------------------------------
          // 5. Category grid (with loading / empty / error states)
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: _CategorySection(ctrl: ctrl, campusId: campusId),
          ),

          // ------------------------------------------------------------------
          // 6. Footer
          // ------------------------------------------------------------------
          const SliverToBoxAdapter(child: TeamFooter()),

          // Bottom safe area so the last item isn't hidden behind the nav bar.
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _BestsellerSection — Handles the 3 states for the bestseller data.
// ---------------------------------------------------------------------------
class _BestsellerSection extends StatelessWidget {
  final HomeController ctrl;
  final String campusId;

  const _BestsellerSection({required this.ctrl, required this.campusId});

  @override
  Widget build(BuildContext context) {
    if (ctrl.isLoading) {
      return const LoadingView(count: 4, height: 240);
    }
    if (ctrl.error != null) {
      return ErrorView(
        message: ctrl.error!,
        onRetry: () => ctrl.retry(campusId),
      );
    }
    if (ctrl.bestsellers.isEmpty) {
      return const EmptyView(message: 'No bestsellers on this campus yet.');
    }
    return BestsellerCarousel(items: ctrl.bestsellers);
  }
}

// ---------------------------------------------------------------------------
// _CategorySection — Handles the 3 states for the categories data.
// ---------------------------------------------------------------------------
class _CategorySection extends StatelessWidget {
  final HomeController ctrl;
  final String campusId;

  const _CategorySection({required this.ctrl, required this.campusId});

  @override
  Widget build(BuildContext context) {
    if (ctrl.isLoading) {
      return const GridLoadingView(count: 9);
    }
    if (ctrl.error != null) {
      // Error already shown above in bestsellers section; don't duplicate.
      return const SizedBox.shrink();
    }
    if (ctrl.categories.isEmpty) {
      return const EmptyView(message: 'No categories yet.');
    }
    return CategoryGrid(categories: ctrl.categories);
  }
}
