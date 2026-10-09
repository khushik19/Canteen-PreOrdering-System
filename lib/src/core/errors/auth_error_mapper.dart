import 'package:firebase_auth/firebase_auth.dart';

// ---------------------------------------------------------------------------
// AuthErrorMapper — converts FirebaseAuthException codes into friendly text.
//
// Usage:  catch (e) { errorMessage = AuthErrorMapper.map(e); }
//
// We NEVER show raw Firebase error text to users. This mapper translates
// cryptic codes like 'wrong-password' into messages like
// "Incorrect email or password."
// ---------------------------------------------------------------------------

class AuthErrorMapper {
  AuthErrorMapper._();

  /// Takes any exception and returns a user-friendly error string.
  ///
  /// If the exception is a [FirebaseAuthException], it maps the code.
  /// Otherwise it returns a generic fallback message.
  static String map(Object exception) {
    if (exception is FirebaseAuthException) {
      return _mapCode(exception.code);
    }
    // Generic fallback for non-Firebase errors (e.g. network issues).
    return 'Something went wrong. Please try again.';
  }

  /// Maps a Firebase Auth error code to a friendly message.
  static String _mapCode(String code) {
    switch (code) {
      // --- Sign in errors ---
      case 'invalid-email':
        return "That email address doesn't look right.";
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // We combine these to avoid revealing whether an email exists.
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Contact the canteen.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a bit and try again.';

      // --- Sign up errors ---
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in.';
      case 'weak-password':
        return 'Please choose a stronger password.';

      // --- Network ---
      case 'network-request-failed':
        return 'No internet connection. Please try again.';

      // --- Catch-all ---
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
