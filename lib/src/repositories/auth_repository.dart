import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../datasources/auth_remote_datasource.dart';
import '../core/errors/auth_error_mapper.dart';

// ---------------------------------------------------------------------------
// AuthRepository — the bridge between the controller and Firebase.
//
// It combines AuthService (FirebaseAuth) and AuthRemoteDatasource (Firestore)
// to give the controller clean methods that return UserModel.
//
// Key responsibility: if sign-up creates an Auth account but the Firestore
// write fails, the repository cleans up (deletes the auth user) so we
// never leave a half-created account.
// ---------------------------------------------------------------------------

class AuthRepository {
  final AuthService _authService = AuthService();
  final AuthRemoteDatasource _datasource = AuthRemoteDatasource();

  // --- Stream (for persistent login) --------------------------------------

  /// Exposes the auth state stream so the controller can listen to it.
  Stream<User?> authStateChanges() => _authService.authStateChanges();

  // --- Sign up ------------------------------------------------------------

  /// Creates a new student account:
  /// 1. Creates the FirebaseAuth user.
  /// 2. Sets the display name.
  /// 3. Writes the users/{uid} doc in Firestore.
  /// 4. If step 3 fails, deletes the auth user (rollback).
  ///
  /// Returns the new [UserModel] on success.
  /// Throws a [String] with a friendly error message on failure.
  Future<UserModel> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String campusId,
  }) async {
    UserCredential? credential;
    try {
      // Step 1: Create the Firebase Auth account.
      credential = await _authService.signUp(email, password);
      final user = credential.user!;

      // Step 2: Set the display name on the Auth profile.
      await user.updateDisplayName(name.trim());

      // Step 3: Build the UserModel and write it to Firestore.
      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim().toLowerCase(),
        role: UserRole.student, // always student from the app
        campusId: campusId,
      );
      await _datasource.createUser(userModel);

      return userModel;
    } catch (e) {
      // Rollback: if we created an auth user but Firestore failed,
      // delete the auth user so we don't leave a half-created account.
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (deleteError) {
          debugPrint('Rollback failed: could not delete auth user: $deleteError');
        }
      }
      // Re-throw with a friendly message.
      throw AuthErrorMapper.map(e);
    }
  }

  // --- Sign in ------------------------------------------------------------

  /// Signs in and fetches the user doc.
  ///
  /// Returns the [UserModel] on success.
  /// Throws a [String] with a friendly error message on failure.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signIn(email, password);
      final uid = credential.user!.uid;

      // Fetch the user doc from Firestore.
      final userModel = await _datasource.fetchUser(uid);

      if (userModel == null) {
        // Edge case: Auth account exists but Firestore doc is missing
        // (signup was interrupted). Create a default student doc.
        final fallback = UserModel(
          uid: uid,
          name: credential.user!.displayName ?? '',
          phone: '',
          email: credential.user!.email ?? email,
          role: UserRole.student,
          campusId: 'pimr_ug',
        );
        await _datasource.createUser(fallback);
        return fallback;
      }

      return userModel;
    } catch (e) {
      if (e is String) rethrow; // already a friendly message
      throw AuthErrorMapper.map(e);
    }
  }

  // --- Fetch user (for persistent login) ----------------------------------

  /// Fetches the user doc for the given [uid].
  /// Returns null if the doc doesn't exist.
  Future<UserModel?> fetchUser(String uid) async {
    try {
      return await _datasource.fetchUser(uid);
    } catch (e) {
      debugPrint('fetchUser failed: $e');
      return null;
    }
  }

  // --- Password reset -----------------------------------------------------

  /// Sends a password-reset email.
  /// Throws a [String] with a friendly error message on failure.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
    } catch (e) {
      throw AuthErrorMapper.map(e);
    }
  }

  // --- Sign out ------------------------------------------------------------

  /// Signs out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
