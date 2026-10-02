import 'package:flutter/material.dart';

class TeamMember {
  final String id;
  final String name;
  final String role;
  final String area;
  final String description;
  final String initials;
  final Color accentColor;
  final List<String> tags;
  final String? photoUrl;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.area,
    required this.description,
    required this.initials,
    required this.accentColor,
    required this.tags,
    this.photoUrl,
  });
}

class TeamController {
  static const List<TeamMember> members = [
    TeamMember(
      id: 'a',
      name: 'Person A',
      role: 'Core, Auth & Menu Lead',
      area: 'Core Architecture, Auth & Menu',
      description:
          'Built the app foundation, state management architecture, secure Firebase authentication, and smooth cafeteria menu browsing experience.',
      initials: 'PA',
      accentColor: Color(0xFFFF5252), // Vivid Coral Red
      tags: ['Flutter', 'Firebase Auth', 'Navigation', 'Design System'],
    ),
    TeamMember(
      id: 'b',
      name: 'Person B',
      role: 'Cart, Payments & Favourites',
      area: 'Cart, Payments & Favourites',
      description:
          'Engineered the real-time cart state, seamless checkout pipeline, Razorpay payment gateway integration, and user favourites sync.',
      initials: 'PB',
      accentColor: Color(0xFF00E5FF), // Celestial Cyan
      tags: ['Cart State', 'Razorpay', 'Checkout', 'Favourites'],
    ),
    TeamMember(
      id: 'c',
      name: 'Person C',
      role: 'Vendor Platform & Operations',
      area: 'Vendor Interface & Order Queue',
      description:
          'Created the cafeteria vendor dashboard, live order management queue, real-time item availability controls, and analytics reporting.',
      initials: 'PC',
      accentColor: Color(0xFFB388FF), // Cosmic Purple
      tags: ['Vendor Dashboard', 'Order Queue', 'Live Updates', 'Analytics'],
    ),
    TeamMember(
      id: 'd',
      name: 'Person D',
      role: 'Flash Sales, Profile & Alerts',
      area: 'Flash Sale, Profile & Notifications',
      description:
          'Architected high-concurrency flash sale claims, live countdown timers, user profile hub with order history, and FCM push notifications.',
      initials: 'PD',
      accentColor: Color(0xFFFFD54F), // Solar Gold
      tags: ['Flash Sales', 'Push Alerts', 'Profile Hub', 'Concurrency'],
    ),
  ];
}
