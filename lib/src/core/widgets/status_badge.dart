import 'package:flutter/material.dart';

enum OrderStatusType { accepted, preparing, ready, completed, rejected }

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({super.key, required this.text, required this.color});

  /// Convenience constructor for order statuses â€” keeps colors consistent
  /// everywhere the badge is used (Profile, Vendor Dashboard).
  factory StatusBadge.orderStatus(OrderStatusType status) {
    switch (status) {
      case OrderStatusType.accepted:
        return StatusBadge(text: 'Accepted', color: const Color(0xFF3B82F6));
      case OrderStatusType.preparing:
        return StatusBadge(text: 'Preparing', color: const Color(0xFFF59E0B));
      case OrderStatusType.ready:
        return StatusBadge(text: 'Ready', color: const Color(0xFF10B981));
      case OrderStatusType.completed:
        return StatusBadge(text: 'Completed', color: const Color(0xFF6B7280));
      case OrderStatusType.rejected:
        return StatusBadge(text: 'Rejected', color: const Color(0xFFEF4444));
    }
  }

  /// Convenience constructor for flash sale discount tags, e.g. "30% OFF"
  factory StatusBadge.discount(int percentOff) {
    return StatusBadge(
      text: '$percentOff% OFF',
      color: const Color(0xFFDC2626),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

