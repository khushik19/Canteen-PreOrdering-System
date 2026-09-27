import 'package:flutter/material.dart';
import 'status_badge.dart';

class OrderStatusCard extends StatelessWidget {
  final String orderId;
  final String itemsSummary; // e.g. "Maggi x1, Cold Coffee x1"
  final double totalAmount;
  final OrderStatusType status;
  final String pickupTime; // formatted, e.g. "1:45 PM"
  final VoidCallback? onTap;

  const OrderStatusCard({
    super.key,
    required this.orderId,
    required this.itemsSummary,
    required this.totalAmount,
    required this.status,
    required this.pickupTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#$orderId',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                StatusBadge.orderStatus(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              itemsSummary,
              style: TextStyle(color: theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Pickup: $pickupTime',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}