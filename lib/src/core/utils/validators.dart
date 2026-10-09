// ---------------------------------------------------------------------------
// Validators — pure functions for form validation.
//
// Usage:  TextFormField(validator: Validators.email)
//
// These are pure functions (no side effects, no Firebase). Easy to test.
// Each returns null if valid, or an error string if invalid.
// ---------------------------------------------------------------------------

class Validators {
  Validators._();

  /// Validates a person's name: required, 2-50 characters after trimming.
  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter your name';
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    if (trimmed.length > 50) return 'Name must be less than 50 characters';
    return null; // valid
  }

  /// Validates an Indian mobile number: exactly 10 digits, starts with 6-9.
  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter your mobile number';
    // Indian mobile: starts with 6, 7, 8, or 9, followed by 9 more digits.
    final regex = RegExp(r'^[6-9]\d{9}$');
    if (!regex.hasMatch(trimmed)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  /// Validates an email address: required, must look like an email.
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter your email';
    // Simple but effective email pattern.
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!regex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates a password: at least 8 characters.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Validates confirm password: must match the original password.
  ///
  /// Usage: TextFormField(validator: (v) => Validators.confirmPassword(v, _passwordController.text))
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return "Passwords don't match";
    return null;
  }

  /// Validates that a campus has been selected (not null or empty).
  static String? campus(String? value) {
    if (value == null || value.isEmpty) return 'Please select your campus';
    return null;
  }
}
