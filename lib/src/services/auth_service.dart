import 'package:firebase_auth/firebase_auth.dart';

// ---------------------------------------------------------------------------
// AuthService — thin wrapper around FirebaseAuth.
//
// This is the ONLY place in the app that talks to FirebaseAuth directly.
// The repository calls this; screens never touch it.
//
// Why a wrapper? So we can swap the implementation for testing later,
// and so all auth calls go through one place.
// ---------------------------------------------------------------------------

class AuthService {
  // Use the default FirebaseAuth instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Streams & getters --------------------------------------------------

  /// A stream that emits whenever the user signs in or out.
  /// The router listens to this (via AuthController) to decide redirects.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// The currently signed-in Firebase user, or null if signed out.
  User? get currentFirebaseUser => _auth.currentUser;

  // --- Sign up ------------------------------------------------------------

  /// Creates a new user with email and password.
  /// Returns a [UserCredential] with the new user's uid.
  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  // --- Sign in ------------------------------------------------------------

  /// Signs in an existing user with email and password.
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  // --- Password reset -----------------------------------------------------

  /// Sends a password reset email to the given address.
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  // --- Sign out ------------------------------------------------------------

  /// Signs the current user out.
  Future<void> signOut() => _auth.signOut();
}
