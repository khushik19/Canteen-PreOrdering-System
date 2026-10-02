import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'team_controller.dart';
import 'widgets/cosmic_background.dart';
import 'widgets/team_member_card.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _lastTime = 0.0;
  bool _initializedPositions = false;
  Size _lastSize = Size.zero;

  // 4 floating members
  late final List<_BouncingMember> _bouncers;

  // Size of each floating avatar unit
  static const double _itemWidth = 84.0;
  static const double _itemHeight = 106.0;

  @override
  void initState() {
    super.initState();

    final members = TeamController.members;
    final random = Random();

    // Initialize 4 floating entities
    _bouncers = [
      _BouncingMember(
        member: members[0],
        initialVelocity: const Offset(65.0, 50.0),
        wobbleSpeed: 2.2,
        wobblePhase: random.nextDouble() * pi * 2,
      ),
      _BouncingMember(
        member: members[1],
        initialVelocity: const Offset(-58.0, 62.0),
        wobbleSpeed: 2.5,
        wobblePhase: random.nextDouble() * pi * 2,
      ),
      _BouncingMember(
        member: members[2],
        initialVelocity: const Offset(62.0, -54.0),
        wobbleSpeed: 2.0,
        wobblePhase: random.nextDouble() * pi * 2,
      ),
      _BouncingMember(
        member: members[3],
        initialVelocity: const Offset(-52.0, -60.0),
        wobbleSpeed: 2.7,
        wobblePhase: random.nextDouble() * pi * 2,
      ),
    ];

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onTick);

    _ticker.repeat();
  }

  void _onTick() {
    final now = DateTime.now().microsecondsSinceEpoch / 1000000.0;
    if (_lastTime > 0.0 && _initializedPositions) {
      final dt = (now - _lastTime).clamp(0.0, 0.05);
      _updatePhysics(dt);
    }
    _lastTime = now;
  }

  void _initPositionsIfNeeded(Size size, EdgeInsets padding) {
    if (_initializedPositions && size == _lastSize) return;

    _lastSize = size;
    final minX = 16.0;
    final maxX = (size.width - _itemWidth - 16.0).clamp(minX, double.infinity);
    final minY = padding.top + kToolbarHeight + 12.0;
    final maxY =
        (size.height - _itemHeight - padding.bottom - 60.0).clamp(minY, double.infinity);

    // Distribute into 4 non-overlapping quadrants
    if (!_initializedPositions) {
      _bouncers[0].position = Offset(minX + 20, minY + 20); // Top Left
      _bouncers[1].position = Offset(maxX - 20, minY + 35); // Top Right
      _bouncers[2].position = Offset(minX + 35, maxY - 30); // Bottom Left
      _bouncers[3].position = Offset(maxX - 35, maxY - 40); // Bottom Right
      _initializedPositions = true;
    } else {
      // Re-clamp if window/orientation resized
      for (final b in _bouncers) {
        final cx = b.position.dx.clamp(minX, maxX);
        final cy = b.position.dy.clamp(minY, maxY);
        b.position = Offset(cx, cy);
      }
    }
  }

  void _updatePhysics(double dt) {
    final size = _lastSize;
    if (size.width <= 0 || size.height <= 0) return;

    final mediaQuery = MediaQuery.of(context);
    final minX = 16.0;
    final maxX = (size.width - _itemWidth - 16.0).clamp(minX, double.infinity);
    final minY = mediaQuery.padding.top + kToolbarHeight + 12.0;
    final maxY = (size.height - _itemHeight - mediaQuery.padding.bottom - 60.0)
        .clamp(minY, double.infinity);

    setState(() {
      for (final b in _bouncers) {
        b.position += b.velocity * dt;
        b.wobblePhase += b.wobbleSpeed * dt;

        // Bounce horizontal walls
        if (b.position.dx <= minX) {
          b.position = Offset(minX, b.position.dy);
          b.velocity = Offset(b.velocity.dx.abs(), b.velocity.dy);
        } else if (b.position.dx >= maxX) {
          b.position = Offset(maxX, b.position.dy);
          b.velocity = Offset(-b.velocity.dx.abs(), b.velocity.dy);
        }

        // Bounce vertical walls
        if (b.position.dy <= minY) {
          b.position = Offset(b.position.dx, minY);
          b.velocity = Offset(b.velocity.dx, b.velocity.dy.abs());
        } else if (b.position.dy >= maxY) {
          b.position = Offset(b.position.dx, maxY);
          b.velocity = Offset(b.velocity.dx, -b.velocity.dy.abs());
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _showMemberModal(BuildContext context, TeamMember member) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131522),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: member.accentColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: member.accentColor.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              TeamMemberCard.fromMember(member, isDark: true),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllMembersSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: const Color(0xFF11131E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.group_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    const Text(
                      'All Team Members',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: MediaQuery.of(ctx).padding.bottom + 20,
                  ),
                  itemCount: TeamController.members.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final member = TeamController.members[idx];
                    return TeamMemberCard.fromMember(member, isDark: true);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Meet the Team',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'View All Members',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            onPressed: () => _showAllMembersSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _initPositionsIfNeeded(size, mediaQuery.padding);

          return Stack(
            children: [
              // 1. Cosmic starfield background
              const CosmicBackground(),

              // 2. Bouncing Team Members
              for (final bouncer in _bouncers)
                Positioned(
                  left: bouncer.position.dx,
                  top: bouncer.position.dy,
                  child: GestureDetector(
                    onTap: () => _showMemberModal(context, bouncer.member),
                    child: Transform.rotate(
                      angle: sin(bouncer.wobblePhase) * 0.16,
                      child: _buildAvatarUnit(bouncer.member),
                    ),
                  ),
                ),

              // 3. Subtle bottom instruction pill
              Positioned(
                bottom: mediaQuery.padding.bottom + 16,
                left: 20,
                right: 20,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _showAllMembersSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131522).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tap a floating astronaut • View All',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatarUnit(TeamMember member) {
    return SizedBox(
      width: _itemWidth,
      height: _itemHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing Orb
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  member.accentColor.withValues(alpha: 0.95),
                  member.accentColor.withValues(alpha: 0.4),
                  const Color(0xFF10121C),
                ],
                stops: const [0.2, 0.7, 1.0],
              ),
              border: Border.all(
                color: member.accentColor.withValues(alpha: 0.85),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: member.accentColor.withValues(alpha: 0.6),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: member.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      member.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitialsText(member),
                    ),
                  )
                : _buildInitialsText(member),
          ),
          const SizedBox(height: 6),
          // Name with dark shadow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: member.accentColor.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              member.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsText(TeamMember member) {
    return Center(
      child: Text(
        member.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: Colors.black87,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncingMember {
  final TeamMember member;
  Offset position;
  Offset velocity;
  final double wobbleSpeed;
  double wobblePhase;

  _BouncingMember({
    required this.member,
    required Offset initialVelocity,
    required this.wobbleSpeed,
    required this.wobblePhase,
  })  : position = Offset.zero,
        velocity = initialVelocity;
}
