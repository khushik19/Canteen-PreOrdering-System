import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AppColors — the single source of truth for every color in the app.
//
// Usage:  import 'package:canteen_crave/src/core/theme/theme.dart';
//         Container(color: AppColors.primary)
//
// Rules:
//   • Orange is the ONLY accent — use it for primary buttons, active states
//     and highlights.
//   • Never hardcode a Color(...) anywhere else in the codebase.
// ---------------------------------------------------------------------------

class AppColors {
  AppColors._(); // prevent instantiation

  // --- Brand / accent ---------------------------------------------------
  static const primary     = Color(0xFFFF6B35); // main orange
  static const primaryDark = Color(0xFFE5541F); // pressed / dark variant

  // --- Backgrounds & surfaces -------------------------------------------
  static const background  = Color(0xFFFFF8F3); // warm cream page background
  static const surface     = Color(0xFFFFFFFF); // card / sheet background

  // --- Text --------------------------------------------------------------
  static const textDark    = Color(0xFF1E1E1E); // headings, primary text
  static const textMuted   = Color(0xFF7A7A7A); // secondary / caption text

  // --- Semantic ----------------------------------------------------------
  static const success     = Color(0xFF2E9E5B); // order ready, success toast
  static const error       = Color(0xFFD64545); // validation, failure

  // --- Misc --------------------------------------------------------------
  static const divider     = Color(0xFFEEEEEE); // thin separators
  static const shadow      = Color(0x14000000); // 8 % black for card shadows
}
