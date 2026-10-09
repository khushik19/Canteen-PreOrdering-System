import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------------------------
// UserRole — an enum so we never compare raw strings in app code.
//
// Usage:  if (user.role == UserRole.vendor) { ... }
//
// If Firestore has an unknown value (e.g. typo), we fall back to `student`
// to avoid crashing the app.
// ---------------------------------------------------------------------------

enum UserRole {
  student,
  vendor;

  /// Safely parse a string from Firestore into a UserRole.
  /// Returns [UserRole.student] if the value is null or unrecognised.
  static UserRole fromString(String? value) {
    switch (value) {
      case 'vendor':
        return UserRole.vendor;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}

// ---------------------------------------------------------------------------
// UserModel — represents one user document from Firestore `users/{uid}`.
//
// This is a "dumb" data class: no UI code, no Firebase logic.
// Everyone on the team reads this model via AuthController.currentUser.
//
// Fields match the Firestore schema in PROJECT_CONTEXT.md Section 6:
//   name, phone, email, role, campusId, createdAt, fcmToken?
// ---------------------------------------------------------------------------

class UserModel {
  final String uid;
  final String name;
  final String phone;       // 10 digits, no +91 prefix stored
  final String email;
  final UserRole role;
  final String campusId;
  final DateTime? createdAt; // null when creating (server sets it)
  final String? fcmToken;    // set later by Person D's notification service

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.campusId,
    this.createdAt,
    this.fcmToken,
  });

  // --- Convenience getters ------------------------------------------------

  /// True if this user is a vendor (canteen staff).
  bool get isVendor => role == UserRole.vendor;

  /// True if this user is a student.
  bool get isStudent => role == UserRole.student;

  // --- Firestore serialisation --------------------------------------------

  /// Create a UserModel from a Firestore document snapshot.
  ///
  /// [map] is the document data, [uid] is the document ID.
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      campusId: map['campusId'] as String? ?? 'pimr_ug',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      fcmToken: map['fcmToken'] as String?,
    );
  }

  /// Convert to a map for writing to Firestore.
  ///
  /// Uses `FieldValue.serverTimestamp()` for `createdAt` so the server
  /// sets the time (avoids client clock drift).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,          // 'student' or 'vendor'
      'campusId': campusId,
      'createdAt': FieldValue.serverTimestamp(),
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  /// Create a copy with some fields changed.
  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? campusId,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      campusId: campusId ?? this.campusId,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: ${role.name})';
}
