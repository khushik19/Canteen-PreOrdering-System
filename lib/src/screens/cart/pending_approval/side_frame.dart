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

  // How far the cluster travels during a transition. Deliberately modest
  // (not a full screen height) — keeps the motion quick and cheap, and
  // the brief's "enters from below" only needs to read as a conveyor
  // pull-in, not a literal off-screen entrance.
  static const _travelDistance = 170.0;

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
    return Stack(
      children: [
        for (final preset in sideFramePresets)
          Align(
            alignment: preset.alignment,
            child: Transform.rotate(
              angle: preset.rotation,
              child: Opacity(
                opacity: preset.opacity,
                child: FoodVisual(food: food, size: preset.size),
              ),
            ),
          ),
      ],
    );
  }
}