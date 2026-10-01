import 'package:flutter/material.dart';
import 'team_controller.dart';
import 'widgets/team_member_card.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Team')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Canteen Crave is built by a team of four developers.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...TeamController.members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TeamMemberCard(
                name: member.name,
                role: member.role,
                area: member.area,
                photoUrl: member.photoUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}