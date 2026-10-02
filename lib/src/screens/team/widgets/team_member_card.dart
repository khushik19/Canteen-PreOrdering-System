import 'package:flutter/material.dart';
import '../team_controller.dart';

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String? area;
  final String? photoUrl;
  final String? description;
  final Color? accentColor;
  final List<String>? tags;
  final bool isDark;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    this.area,
    this.photoUrl,
    this.description,
    this.accentColor,
    this.tags,
    this.isDark = true,
  });

  factory TeamMemberCard.fromMember(TeamMember member, {bool isDark = true}) {
    return TeamMemberCard(
      name: member.name,
      role: member.role,
      area: member.area,
      photoUrl: member.photoUrl,
      description: member.description,
      accentColor: member.accentColor,
      tags: member.tags,
      isDark: isDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveAccent = accentColor ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161824) : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: effectiveAccent.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveAccent.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      effectiveAccent.withValues(alpha: 0.8),
                      effectiveAccent.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveAccent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildInitials(),
                        ),
                      )
                    : _buildInitials(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : theme.textTheme.titleMedium?.color,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: effectiveAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: effectiveAccent.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 12,
                          color: effectiveAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (area != null && area!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.space_dashboard_rounded,
                  size: 15,
                  color: effectiveAccent.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    area!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFC5C6D0) : theme.hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description!,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? const Color(0xFFD4D6E2) : theme.hintColor,
              ),
            ),
          ],
          if (tags != null && tags!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags!.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitials() {
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
    return Center(
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
