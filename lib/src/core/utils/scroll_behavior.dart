import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AppScrollBehavior — Enables smooth mouse-dragging on desktop and web.
//
// Desktop mouse users cannot touch-drag horizontal lists by default in Flutter.
// This allows mouse click-and-drag for food carousels (RULES.md Section 5.7).
// ---------------------------------------------------------------------------

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
