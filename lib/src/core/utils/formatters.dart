import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// AppFormatters — Formatting helpers for Indian currency (₹) and numbers.
//
// Rules from RULES.md Section 8.6:
//   Money format: NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
// ---------------------------------------------------------------------------

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _rupeeFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Format an amount into Indian Rupees (e.g. 70 -> '₹70').
  static String formatRupees(num amount) {
    return _rupeeFormat.format(amount);
  }
}
