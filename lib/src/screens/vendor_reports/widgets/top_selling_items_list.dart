import 'package:flutter/material.dart';
import '../../../models/report_model.dart';

class TopSellingItemsList extends StatelessWidget {
  final List<TopSellingItem> items;

  const TopSellingItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E222A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No sales data recorded yet for today',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C3240)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Color(0xFFFF6B00), size: 20),
              SizedBox(width: 8),
              Text(
                'Top Selling Dishes Today',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: idx == 0
                          ? const Color(0xFFFFD700)
                          : idx == 1
                              ? const Color(0xFFC0C0C0)
                              : idx == 2
                                  ? const Color(0xFFCD7F32)
                                  : const Color(0xFF121418),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: idx < 3 ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.quantitySold} sold',
                        style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '₹${item.totalRevenue.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
