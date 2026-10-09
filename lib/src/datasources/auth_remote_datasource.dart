import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// AuthRemoteDatasource — raw Firestore reads and writes for user documents.
//
// This handles the `users/{uid}` collection. It does NOT touch FirebaseAuth
// (that is AuthService's job). The repository combines both.
// ---------------------------------------------------------------------------

class AuthRemoteDatasource {
  // Reference to the 'users' collection in Firestore.
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection(AppConstants.usersCollection);

  /// Fetch the user document for [uid].
  ///
  /// Returns a [UserModel] if the document exists, or null if it doesn't
  /// (edge case: sign-up was interrupted before the Firestore write).
  Future<UserModel?> fetchUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  /// Create the user document at `users/{uid}`.
  ///
  /// Called right after FirebaseAuth sign-up succeeds.
  /// Uses `set` (not `add`) because we control the document ID (= uid).
  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap());
  }

  /// Update specific fields in an existing user document.
  ///
  /// Useful for updating display name, campus, fcmToken, etc.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update(data);
  }

  /// Delete the user document.
  ///
  /// Used in the rollback scenario: if Firestore write fails after
  /// FirebaseAuth account was created, we delete the auth user AND this doc.
  Future<void> deleteUser(String uid) async {
    await _usersRef.doc(uid).delete();
  }
}
