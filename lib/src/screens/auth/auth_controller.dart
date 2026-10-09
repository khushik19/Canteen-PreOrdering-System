import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// AuthStatus — tracks where we are in the authentication lifecycle.
//
//   unknown         → app just started, checking if user is already logged in
//   unauthenticated → no user is signed in
//   authenticated   → user is signed in, currentUser is available
// ---------------------------------------------------------------------------

enum AuthStatus { unknown, unauthenticated, authenticated }

// ---------------------------------------------------------------------------
// AuthController — the ChangeNotifier that the whole app reads for auth state.
//
// Usage (in a widget):
//   final auth = context.watch<AuthController>();
//   if (auth.status == AuthStatus.authenticated) { ... }
//   auth.currentUser?.name
//
// The router uses `refreshListenable: authController` so it re-evaluates
// redirects whenever auth state changes.
// ---------------------------------------------------------------------------

class AuthController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  // --- State fields -------------------------------------------------------

  /// Current auth status. Starts as `unknown` while we check Firebase.
  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  /// The logged-in user's data from Firestore. Null when signed out.
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// True while a sign-in/sign-up/reset call is in progress.
  /// Use this to show spinners and disable buttons.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// A friendly error message, or null if there is no error.
  /// Cleared automatically before each new action.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Subscription to FirebaseAuth.authStateChanges().
  StreamSubscription<User?>? _authSub;

  // --- Initialisation -----------------------------------------------------

  /// Call this once at app start (from app.dart or main.dart).
  ///
  /// It listens to Firebase auth state changes. When a user is already
  /// logged in (persistent login), it fetches their Firestore doc and
  /// sets status to `authenticated` — so the splash screen is short.
  AuthController() {
    _init();
  }

  void _init() {
    _authSub = _repository.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Called whenever Firebase tells us the auth state changed
  /// (sign in, sign out, or app start with a cached session).
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // No user → signed out.
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } else {
      // User exists → fetch their Firestore doc.
      final userModel = await _repository.fetchUser(firebaseUser.uid);

      if (userModel != null) {
        _currentUser = userModel;
        _status = AuthStatus.authenticated;
      } else {
        // Edge case: auth exists but no Firestore doc.
        // Create a default one so we don't crash.
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          phone: '',
          email: firebaseUser.email ?? '',
          role: UserRole.student,
          campusId: 'pimr_ug',
        );
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    }
  }

  // --- Sign up ------------------------------------------------------------

  /// Creates a new student account.
  /// Returns true on success, false on failure (check [errorMessage]).
  Future<bool> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String campusId,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _repository.signUp(
        name: name,
        phone: phone,
        email: email,
        password: password,
        campusId: campusId,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Sign in ------------------------------------------------------------

  /// Signs in an existing user.
  /// Returns true on success, false on failure (check [errorMessage]).
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Password reset -----------------------------------------------------

  /// Sends a password reset email.
  /// Returns true on success, false on failure (check [errorMessage]).
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.sendPasswordReset(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Sign out -----------------------------------------------------------

  /// Signs out and clears local state.
  /// The auth state listener will set status to `unauthenticated`.
  Future<void> signOut() async {
    await _repository.signOut();
    // The _onAuthStateChanged listener handles the rest.
  }

  // --- Helpers ------------------------------------------------------------

  /// Clears the current error message. Call this when the user starts typing
  /// or navigates away from the error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Cleanup ------------------------------------------------------------

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
