import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

/// TODO (Person D): Implement edit form for name and phone.
/// Wire save button to ProfileController.updateProfile().
class EditProfileSheet extends StatelessWidget {
  final UserModel user;
  const EditProfileSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text('Edit Profile — coming soon'),
    );
  }
}