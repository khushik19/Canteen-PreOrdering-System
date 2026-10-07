import 'package:flutter/material.dart';
import 'food_states.dart';
import 'food_visual.dart';

/// The decorative left/right edge food frame. At rest it's a stationary
/// cluster of large, edge-cropped illustrations (see [sideFramePresets]).
/// During a transition, the whole cluster moves as a single unit:
///
///   current cluster translates UP and exits
///   next cluster enters from BELOW and settles
///
/// This is a real vertical translation (no fade/crossfade/scale as the
/// primary effect) per the brief's "conveyor" reference. Both left- and
/// right-side presets animate together, driven by the same controller, so
/// the whole frame reads as one coordinated motion.
class SideFrame extends StatelessWidget {
  final FoodState currentFood;
  final FoodState nextFood;
  final bool isTransitioning;
  final Animation<double> transitionAnimation;

  const SideFrame({
    super.key,
    required this.currentFood,
    required this.nextFood,
    required this.isTransitioning,
    required this.transitionAnimation,
  });

  // How far the cluster travels during a transition. Scaled down to match
  // the smaller illustrations and the shorter ~300ms duration — keeps the
  // motion quick and cheap rather than a long traverse.
  static const _travelDistance = 100.0;

  @override
  Widget build(BuildContext context) {
    if (!isTransitioning) {
      return _Cluster(food: currentFood);
    }
    return AnimatedBuilder(
      animation: transitionAnimation,
      builder: (context, _) {
        final v = Curves.easeInOut.transform(transitionAnimation.value);
        return Stack(
          children: [
            Transform.translate(
              offset: Offset(0, -_travelDistance * v),
              child: _Cluster(food: currentFood),
            ),
            Transform.translate(
              offset: Offset(0, _travelDistance * (1 - v)),
              child: _Cluster(food: nextFood),
            ),
          ],
        );
      },
    );
  }
}

class _Cluster extends StatelessWidget {
  final FoodState food;
  const _Cluster({required this.food});

  @override
  Widget build(BuildContext context) {
    // On narrow (phone-width) screens the side illustrations read as too
    // small at the same literal size used for wider test/desktop views —
    // bump them up slightly so they still feel intentional, without
    // growing them on wider screens where they're already proportionally
    // bigger.
    final isMobileWidth = MediaQuery.of(context).size.width < 600;
    final sizeFactor = isMobileWidth ? 1.2 : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            for (final preset in sideFramePresets)
              Builder(builder: (context) {
                final size = preset.size * sizeFactor;
                // Pixel bleed is relative to the image's own size, not the
                // screen's — e.g. visibleFraction 0.4 always bleeds 60% of
                // THIS image off the edge, regardless of how wide the
                // viewport is.
                final bleed = size * (1 - preset.visibleFraction);
                return Positioned(
                  top: constraints.maxHeight * preset.topFraction,
                  left: preset.side == FrameSide.left ? -bleed : null,
                  right: preset.side == FrameSide.right ? -bleed : null,
                  child: Transform.rotate(
                    angle: preset.rotation,
                    child: Opacity(
                      opacity: preset.opacity,
                      child: FoodVisual(food: food, size: size),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}