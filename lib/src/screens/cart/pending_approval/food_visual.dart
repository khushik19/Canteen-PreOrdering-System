import 'package:flutter/material.dart';
import 'food_states.dart';

/// Renders a food's transparent cut-out asset at the given size. Falls
/// back to its emoji only if the asset is ever missing/misnamed — the
/// real assets are wired in by default now.
class FoodVisual extends StatelessWidget {
  final FoodState food;
  final double size;

  const FoodVisual({super.key, required this.food, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      food.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => Text(
        food.emojiFallback,
        style: TextStyle(fontSize: size * 0.72),
      ),
    );
  }
}