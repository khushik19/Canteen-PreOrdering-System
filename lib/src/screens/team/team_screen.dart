import 'package:flutter/material.dart';
import 'widgets/team_member_card.dart';

class _TeamMemberData {
  final String name;
  final String role;
  final String? photoUrl;
  final String? description;

  const _TeamMemberData({
    required this.name,
    required this.role,
    this.photoUrl,
    this.description,
  });
}

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  // Fill in real names/roles/photos for your team.
  // Leave photoUrl null to show initials instead of a broken image.
  static const _team = [
    _TeamMemberData(
      name: 'Person A',
      role: 'Core, Auth & Home/Menu',
      description: 'Built the app foundation, authentication, and browsing experience.',
    ),
    _TeamMemberData(
      name: 'Person B',
      role: 'Cart, Payments & Favourites',
      description: 'Built checkout, Razorpay integration, and favourites.',
    ),
    _TeamMemberData(
      name: 'Person C',
      role: 'Vendor Interface',
      description: 'Built the canteen-side dashboard, menu management, and reports.',
    ),
    _TeamMemberData(
      name: 'Person D',
      role: 'Flash Sale, Profile & Notifications',
      description: 'Built flash sales, push notifications, and the profile experience.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meet the Team')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Canteen Crave was built by a 4-person student team to solve a '
            'simple problem: 20 minutes isn\'t enough time to wait in line.',
            style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 20),
          for (final member in _team) ...[
            TeamMemberCard(
              name: member.name,
              role: member.role,
              photoUrl: member.photoUrl,
              description: member.description,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}