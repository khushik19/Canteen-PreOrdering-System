import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String? photoUrl;
  final String? area; // area of ownership e.g. "Auth & Home"
  final VoidCallback? onTap;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    this.photoUrl,
    this.area,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Avatar(photoUrl: photoUrl, name: name),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (area != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        area!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
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

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;

  const _Avatar({this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return CircleAvatar(
        radius: 28,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl!,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                const CircularProgressIndicator(strokeWidth: 2),
            errorWidget: (_, __, ___) => _initials(name),
          ),
        ),
      );
    }
    return CircleAvatar(radius: 28, child: _initials(name));
  }

  Widget _initials(String name) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    return Text(
      initials,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}