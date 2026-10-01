import 'package:flutter/material.dart';

class TeamMember {
  final String name;
  final String role;
  final String area;
  final String? photoUrl;

  const TeamMember({
    required this.name,
    required this.role,
    required this.area,
    this.photoUrl,
  });
}

class TeamController extends ChangeNotifier {
  // Update names/photos once the team confirms — photos can be uploaded
  // to Firebase Storage and URLs added here, or fetched from Firestore.
  static const List<TeamMember> members = [
    TeamMember(
      name: 'Person A',
      role: 'Full Stack Developer',
      area: 'Auth, Home Screen',
    ),
    TeamMember(
      name: 'Person B',
      role: 'Full Stack Developer',
      area: 'Cart, Orders, Razorpay',
    ),
    TeamMember(
      name: 'Person C',
      role: 'Full Stack Developer',
      area: 'Vendor Dashboard, Menu Management',
    ),
    TeamMember(
      name: 'Person D',
      role: 'Full Stack Developer',
      area: 'Flash Sale, Notifications, Profile',
    ),
  ];
}