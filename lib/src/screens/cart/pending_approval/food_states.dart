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
    microcopy: 'canteen me meeting chal rahi. 😭',
  ),
  FoodState(
    name: 'Fried Rice',
    assetPath: 'assets/images/food/fried_rice_cutout.png',
    emojiFallback: '🍛',
    tint: Color(0xFFFDF6DC),
    microcopy: 'bas bhaiya haan bol dein… 👀',
  ),
  FoodState(
    name: 'Sandwich',
    assetPath: 'assets/images/food/sandwich_cutout.png',
    emojiFallback: '🥪',
    tint: Color(0xFFEFF3E6),
    microcopy: 'thoda sa cooking arc...',
  ),
  FoodState(
    name: 'Pasta',
    assetPath: 'assets/images/food/pasta_cutout.png',
    emojiFallback: '🍝',
    tint: Color(0xFFF7E6DC),
    microcopy: 'canteen se green signal chahiye in life.',
  ),
  FoodState(
    name: 'Roll',
    assetPath: 'assets/images/food/roll_cutout.png',
    emojiFallback: '🌯',
    tint: Color(0xFFFBEDE3),
    microcopy: '“hmm, dekhte hain..”: prolly canteen peeps',
  ),
  FoodState(
    name: 'Indian dish',
    assetPath: 'assets/images/food/thali_cutout.png',
    emojiFallback: '🍛',
    tint: Color(0xFFF7ECE4),
    microcopy: 'haan milte hi done✨',
  ),
];

/// A hand-arranged (not mirrored, not grid-aligned) decorative position
/// for the left/right edge frame. [alignment] is allowed to exceed the
/// normal ±1 range on purpose — values like -1.2 push the illustration
/// partly outside the viewport so the screen edge crops it naturally
/// (the enclosing Stack clips at the screen bounds). [size] is the
/// literal rendered size in logical pixels, not a multiplier — these are
/// meant to read as large, not as small decorative repeats.
///
/// Kept deliberately within the upper-to-middle band (roughly
/// y: -0.8 to 0.1) and off either edge (x beyond ±1) so the frame never
/// reads as a top or bottom border and never competes with the center
/// content column.
class SideFoodPreset {
  final Alignment alignment;
  final double size;
  final double rotation;
  final double opacity;

  const SideFoodPreset({
    required this.alignment,
    required this.size,
    required this.rotation,
    required this.opacity,
  });
}

const sideFramePresets = [
  // Left side
  SideFoodPreset(alignment: Alignment(-1.2, -0.75), size: 180, rotation: -0.17, opacity: 0.5),
  SideFoodPreset(alignment: Alignment(-1.28, -0.12), size: 150, rotation: 0.22, opacity: 0.36),
  // Right side — intentionally not a mirror of the left (different
  // sizes, heights and rotations)
  SideFoodPreset(alignment: Alignment(1.22, -0.55), size: 160, rotation: 0.2, opacity: 0.46),
  SideFoodPreset(alignment: Alignment(1.12, 0.05), size: 195, rotation: -0.24, opacity: 0.4),
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