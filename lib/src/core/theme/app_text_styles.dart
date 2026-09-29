import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

// ---------------------------------------------------------------------------
// AppTextStyles — three tiers of typography, all using Poppins.
//
// Usage:  import 'package:canteen_crave/src/core/theme/theme.dart';
//         Text('Hello', style: AppTextStyles.title)
//
// Tiers:
//   title   — 22px bold   (screen headings, section titles)
//   body    — 15px regular (descriptions, form labels)
//   caption — 12px regular (timestamps, hints, small labels)
// ---------------------------------------------------------------------------

class AppTextStyles {
  AppTextStyles._();

  // Base font family — Poppins gives the app a warm, modern feel.
  static String get _fontFamily => GoogleFonts.poppins().fontFamily!;

  // --- Title (22px, bold, dark) ------------------------------------------
  static TextStyle get title => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.3,
      );

  // --- Body (15px, regular, dark) ----------------------------------------
  static TextStyle get body => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
        height: 1.5,
      );

  // --- Caption (12px, regular, muted) ------------------------------------
  static TextStyle get caption => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      );

  // --- Helpers (common variations) ---------------------------------------

  /// Bold version of body — for prices, card titles, etc.
  static TextStyle get bodyBold => body.copyWith(fontWeight: FontWeight.w600);

  /// Smaller title — for card headings inside lists.
  static TextStyle get titleSmall => title.copyWith(fontSize: 18);

  /// Button label — 15px semi-bold, white (override color as needed).
  static TextStyle get button => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.0,
      );
}
