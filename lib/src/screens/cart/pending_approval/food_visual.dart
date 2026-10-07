import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'food_states.dart';

/// Renders a food's transparent cut-out asset at the given size. No emoji
/// fallback — if an asset is ever missing/misnamed this renders blank in
/// release builds, per explicit instruction never to show an emoji.
///
/// TODO(debug): in debug builds only, a failed load instead shows a red
/// outlined box + broken-image icon and logs the exact asset path that
/// failed, so a missing/unregistered asset is obvious at a glance instead
/// of silently rendering nothing. Remove this debug branch once asset
/// loading is confirmed working everywhere (i.e. this never fires).
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
      errorBuilder: (context, error, stack) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('FoodVisual: failed to load "${food.assetPath}" — $error');
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 1)),
            child: Icon(Icons.broken_image_outlined, size: size * 0.4, color: Colors.red),
          );
        }
        return SizedBox(width: size, height: size);
      },
    );
  }
}