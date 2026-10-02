class AuthRepository {
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    // Stub implementation until Person A wires up Auth & Firestore user sync
  }
}
