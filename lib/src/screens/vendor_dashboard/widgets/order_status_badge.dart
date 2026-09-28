import 'package:flutter/material.dart';
import '../../../models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status) {
      case OrderStatus.placed:
        return const Color(0xFF3B82F6); // Blue
      case OrderStatus.accepted:
        return const Color(0xFF8B5CF6); // Purple
      case OrderStatus.preparing:
        return const Color(0xFFFF9800); // Amber/Orange
      case OrderStatus.ready:
        return const Color(0xFF10B981); // Emerald Green
      case OrderStatus.completed:
        return const Color(0xFF6B7280); // Gray
      case OrderStatus.uncollected:
        return const Color(0xFFEF4444); // Red
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626); // Crimson
    }
  }

  String _getLabel() {
    switch (status) {
      case OrderStatus.placed:
        return 'NEW ORDER';
      case OrderStatus.accepted:
        return 'ACCEPTED';
      case OrderStatus.preparing:
        return 'IN KITCHEN';
      case OrderStatus.ready:
        return 'READY FOR PICKUP';
      case OrderStatus.completed:
        return 'COMPLETED';
      case OrderStatus.uncollected:
        return 'UNCOLLECTED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
