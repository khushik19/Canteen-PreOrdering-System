import 'package:flutter/material.dart';

/// One of the fixed, art-directed food states. Not derived from cart
/// contents — this is a brand interaction, always the same curated
/// sequence (see the design brief).
///
/// NOTE: the brief specified 5 states (Burger/Fries/Sandwich/Roll/Indian
/// dish) as placeholders before real assets existed. The team's actual
/// delivered Menu illustrations are 6 dishes (Burger, Fried Rice,
/// Sandwich, Pasta, Roll, Indian dish/thali) with no plain "Fries" — this
/// list follows the real assets. Swap/reorder here if that's wrong.
class FoodState {
  final String name;
  final String assetPath;
  final String emojiFallback;
  final Color tint;
  final String microcopy;

  const FoodState({
    required this.name,
    required this.assetPath,
    required this.emojiFallback,
    required this.tint,
    required this.microcopy,
  });
}

const foodStates = [
  FoodState(
    name: 'Burger',
    assetPath: 'assets/images/food/burger_cutout.png',
    emojiFallback: '🍔',
    tint: Color(0xFFFBF3E7),
    microcopy: 'Bas thoda sa wait...',
  ),
  FoodState(
    name: 'Fried Rice',
    assetPath: 'assets/images/food/fried_rice_cutout.png',
    emojiFallback: '🍛',
    tint: Color(0xFFFDF6DC),
    microcopy: 'Garam garam ban raha hai...',
  ),
  FoodState(
    name: 'Sandwich',
    assetPath: 'assets/images/food/sandwich_cutout.png',
    emojiFallback: '🥪',
    tint: Color(0xFFEFF3E6),
    microcopy: 'Thoda aur sabr rakho...',
  ),
  FoodState(
    name: 'Pasta',
    assetPath: 'assets/images/food/pasta_cutout.png',
    emojiFallback: '🍝',
    tint: Color(0xFFF7E6DC),
    microcopy: 'Twist aa raha hai...',
  ),
  FoodState(
    name: 'Roll',
    assetPath: 'assets/images/food/roll_cutout.png',
    emojiFallback: '🌯',
    tint: Color(0xFFFBEDE3),
    microcopy: 'Lapet ke aa rahe hain...',
  ),
  FoodState(
    name: 'Indian dish',
    assetPath: 'assets/images/food/thali_cutout.png',
    emojiFallback: '🍛',
    tint: Color(0xFFF7ECE4),
    microcopy: 'Tadka lag raha hai...',
  ),
];

/// Which edge of the screen this decorative item belongs to.
enum FrameSide { left, right }

/// A hand-arranged (not mirrored, not grid-aligned) decorative position
/// for the left/right edge frame.
///
/// [visibleFraction] (0–1) is how much of the image's OWN width stays on
/// screen — e.g. 0.4 means 40% visible, 60% bled off the edge. This is
/// deliberately proportional to the image's own size, not the screen's,
/// so the "peeking in" amount looks consistent on a narrow phone and a
/// wide desktop/web window alike. (An earlier version used Alignment
/// values beyond ±1, which overshoot relative to half the *container*
/// width — on a very wide window that pushed items hundreds of pixels
/// past the edge, fully outside the clip region, so nothing rendered at
/// all. This fixes that.)
///
/// [topFraction] (0–1) positions the item vertically as a fraction of the
/// available height, kept within the upper-to-middle band (roughly 0.1
/// to 0.6) so the frame never reads as a top or bottom border and never
/// sits behind the center content column.
class SideFoodPreset {
  final FrameSide side;
  final double size;
  final double visibleFraction;
  final double topFraction;
  final double rotation;
  final double opacity;

  const SideFoodPreset({
    required this.side,
    required this.size,
    required this.visibleFraction,
    required this.topFraction,
    required this.rotation,
    required this.opacity,
  });
}

const sideFramePresets = [
  // LEFT
  SideFoodPreset(
    side: FrameSide.left,
    size: 115,
    visibleFraction: 0.45,
    topFraction: 0.12,
    rotation: -0.32,
    opacity: 0.40,
  ),
  SideFoodPreset(
    side: FrameSide.left,
    size: 100,
    visibleFraction: 0.38,
    topFraction: 0.30,
    rotation: 0.18,
    opacity: 0.30,
  ),
  SideFoodPreset(
    side: FrameSide.left,
    size: 125,
    visibleFraction: 0.43,
    topFraction: 0.47,
    rotation: -0.08,
    opacity: 0.38,
  ),
  SideFoodPreset(
    side: FrameSide.left,
    size: 105,
    visibleFraction: 0.40,
    topFraction: 0.62,
    rotation: 0.31,
    opacity: 0.28,
  ),

  // RIGHT
  SideFoodPreset(
    side: FrameSide.right,
    size: 110,
    visibleFraction: 0.42,
    topFraction: 0.09,
    rotation: 0.27,
    opacity: 0.38,
  ),
  SideFoodPreset(
    side: FrameSide.right,
    size: 125,
    visibleFraction: 0.46,
    topFraction: 0.27,
    rotation: -0.24,
    opacity: 0.42,
  ),
  SideFoodPreset(
    side: FrameSide.right,
    size: 100,
    visibleFraction: 0.36,
    topFraction: 0.44,
    rotation: 0.34,
    opacity: 0.28,
  ),
  SideFoodPreset(
    side: FrameSide.right,
    size: 115,
    visibleFraction: 0.42,
    topFraction: 0.60,
    rotation: -0.15,
    opacity: 0.36,
  ),
];
/// The floating interactive control — always this specific burger asset,
/// independent of the current food state in [foodStates].
const miniBurger = FoodState(
  name: 'mini-burger',
  assetPath: 'assets/images/food/mini_burger_cutout.png',
  emojiFallback: '🍔',
  tint: Colors.transparent,
  microcopy: '',
);