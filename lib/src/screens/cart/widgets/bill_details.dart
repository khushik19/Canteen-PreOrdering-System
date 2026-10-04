import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';
import '../cart_theme.dart';

class BillDetails extends StatelessWidget {
  final List<CartItemModel> items;
  final double total;

  const BillDetails({super.key, required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CartColors.cardSurface,
        borderRadius: BorderRadius.circular(CartRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bill Details',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: CartColors.textPrimary)),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.quantity > 1 ? '${item.name} × ${item.quantity}' : item.name,
                      style: const TextStyle(fontSize: 13.5, color: CartColors.textPrimary),
                    ),
                  ),
                  Text(
                    '₹${item.lineTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13.5, color: CartColors.textPrimary),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: CartColors.accentSoft),
          ),
          Row(
            children: [
              const Expanded(
                child: Text('Total',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}