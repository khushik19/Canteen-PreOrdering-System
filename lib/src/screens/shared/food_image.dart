import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

// ---------------------------------------------------------------------------
// FoodImage — Displays a food photo, or a clean placeholder icon when
// the URL is empty/missing.
//
// Used by bestseller cards and category tiles.
//
// Rules followed:
//   • Images always have a fixed aspect ratio (no layout jumps).
//   • CachedNetworkImage with placeholder + error fallback (RULES.md Section 7.5).
//   • Empty URL → neutral grey box with a food icon (no broken link icon).
//   • semanticLabel passed through for accessibility (RULES.md Section 6.4).
// ---------------------------------------------------------------------------

class FoodImage extends StatelessWidget {
  /// The URL of the food photo. Pass an empty string ('') for the placeholder.
  final String imageUrl;

  /// Width/height ratio.  Defaults to 4:3 (landscape card).
  final double aspectRatio;

  /// Border radius applied to the image corners. Defaults to AppRadius.card.
  final double borderRadius;

  /// Accessibility label for the image.
  final String? semanticLabel;

  const FoodImage({
    super.key,
    required this.imageUrl,
    this.aspectRatio = 4 / 3,
    this.borderRadius = AppRadius.card,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder box with a food icon – shown when no URL is provided.
    if (imageUrl.isEmpty) {
      return Semantics(
        label: semanticLabel,
        excludeSemantics: semanticLabel == null,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              color: AppColors.primary.withValues(alpha: 0.08),
              child: const Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Real image from network with fade-in.
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel == null,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            // Neutral grey box while loading
            placeholder: (context, url) => Container(
              color: AppColors.primary.withValues(alpha: 0.06),
              child: const Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            // Icon fallback on error
            errorWidget: (context, url, error) => Container(
              color: AppColors.primary.withValues(alpha: 0.06),
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 32,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
