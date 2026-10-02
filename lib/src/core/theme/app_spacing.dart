// ---------------------------------------------------------------------------
// AppSpacing & AppRadius — consistent spacing and corner radii.
//
// Usage:  import 'package:canteen_crave/src/core/theme/theme.dart';
//         Padding(padding: EdgeInsets.all(AppSpacing.m))
//
// Rules:
//   • Spacing uses multiples of 8 only (4 is the exception for tiny gaps).
//   • Screen edge padding is always AppSpacing.m (16).
//   • Cards use AppRadius.card (16). Buttons use AppRadius.button (12).
// ---------------------------------------------------------------------------

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;   // tiny gaps (icon-to-text, chip padding)
  static const double s  = 8.0;   // small gaps
  static const double m  = 16.0;  // default padding, screen edges
  static const double l  = 24.0;  // section gaps
  static const double xl = 32.0;  // large section separators
}

class AppRadius {
  AppRadius._();

  static const double card   = 16.0;  // cards, images, sheets
  static const double button = 12.0;  // buttons, text fields
  static const double chip   = 999.0; // fully rounded chips / badges
}
