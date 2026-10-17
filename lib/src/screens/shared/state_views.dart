import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

// ---------------------------------------------------------------------------
// state_views.dart — Three shared views for data-loading states.
//
// RULES.md Section 8.1: every screen that loads data handles 3 states:
//   • LoadingView  — skeleton placeholder boxes while data is fetching
//   • EmptyView    — friendly "nothing here" message
//   • ErrorView    — friendly error text + Retry button
//
// Usage:
//   if (ctrl.isLoading) return const LoadingView();
//   if (ctrl.error != null) return ErrorView(message: ctrl.error!, onRetry: ctrl.load);
//   if (ctrl.items.isEmpty) return const EmptyView(message: 'No items yet.');
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// LoadingView — A row of animated grey skeleton boxes (one per expected card).
// ---------------------------------------------------------------------------
class LoadingView extends StatelessWidget {
  /// How many skeleton boxes to show (defaults to 3).
  final int count;

  /// Height of each skeleton box.
  final double height;

  const LoadingView({super.key, this.count = 3, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.m),
        itemBuilder: (context, _) => _SkeletonBox(
          width: 160,
          height: height,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GridLoadingView — Grid of skeleton boxes for the category section.
// ---------------------------------------------------------------------------
class GridLoadingView extends StatelessWidget {
  final int count;
  const GridLoadingView({super.key, this.count = 9});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.s,
        crossAxisSpacing: AppSpacing.s,
        childAspectRatio: 1,
      ),
      itemCount: count,
      itemBuilder: (context, _) => const _SkeletonBox(width: double.infinity, height: double.infinity),
    );
  }
}

// ---------------------------------------------------------------------------
// EmptyView — A centred icon + title + subtitle for empty states.
// ---------------------------------------------------------------------------
class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.restaurant_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.m),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ErrorView — Friendly error text + a Retry button.
// ---------------------------------------------------------------------------
class ErrorView extends StatelessWidget {
  final String message;

  /// Called when the user taps "Retry".
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.m),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.m),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SkeletonBox — Internal animated grey placeholder rectangle.
// ---------------------------------------------------------------------------
class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;

  const _SkeletonBox({required this.width, required this.height});

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.04, end: 0.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.textDark.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
    );
  }
}
