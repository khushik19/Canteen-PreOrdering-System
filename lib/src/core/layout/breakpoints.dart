import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// Breakpoints — Single source of truth for responsive screen widths.
//
// Rules from RULES.md Section 5:
//   mobile:  under 600   (phones)
//   tablet:  600 to 1023 (tablets, small windows)
//   desktop: 1024 and up (laptops, monitors)
// ---------------------------------------------------------------------------

enum ScreenSize { mobile, tablet, desktop }

class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;

  /// Content never gets wider than 1200px on wide monitors.
  static const double maxContentWidth = 1200;
}

/// Helper function to get the current [ScreenSize] from the build context.
/// Uses [MediaQuery.sizeOf] for fast, selective rebuilding.
ScreenSize screenSizeOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < Breakpoints.mobile) return ScreenSize.mobile;
  if (w < Breakpoints.tablet) return ScreenSize.tablet;
  return ScreenSize.desktop;
}
