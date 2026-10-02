import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import 'profile_controller.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/order_dashboard_tab.dart';
import 'widgets/help_tab.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? currentUser;

  const ProfileScreen({super.key, this.currentUser});

  static const _defaultUser = UserModel(
    id: 'student_current',
    name: 'Khushi Katiyar',
    email: 'khushi@campus.edu',
    phone: '+91 98765 43210',
  );

  @override
  Widget build(BuildContext context) {
    final effectiveUser = currentUser ?? _defaultUser;

    return ChangeNotifierProvider(
      create: (_) => ProfileController()..setUser(effectiveUser),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Orders'),
                Tab(text: 'Help'),
              ],
            ),
          ),
          body: Column(
            children: [
              const _ProfileHeader(),
              const Expanded(
                child: TabBarView(
                  children: [
                    OrderDashboardTab(),
                    HelpTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        final user = controller.user;
        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: controller.isSaving
                    ? null
                    : () => controller.updateProfilePicture(),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(user.phone ?? user.email ?? '',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => EditProfileSheet(user: user),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
