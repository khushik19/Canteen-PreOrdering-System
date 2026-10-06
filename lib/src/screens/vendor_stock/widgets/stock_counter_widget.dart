import 'package:flutter/material.dart';
import '../../../models/stock_item_model.dart';
import '../../../repositories/stock_repository.dart';

class StockCounterWidget extends StatelessWidget {
  final StockItemModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StockCounterWidget({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final stockRepo = StockRepository();

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isOutOfStock
              ? Colors.redAccent.withValues(alpha: 0.5)
              : item.isLowStock
                  ? const Color(0xFFFFB300).withValues(alpha: 0.5)
                  : const Color(0xFF2C3240),
        ),
      ),
      child: Row(
        children: [
          // Stock status icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF121418),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.isOutOfStock
                  ? Icons.remove_shopping_cart_outlined
                  : item.category.contains('Beverage')
                      ? Icons.local_drink_outlined
                      : item.category.contains('Chocolate')
                          ? Icons.cookie_outlined
                          : Icons.inventory_2_outlined,
              color: item.isOutOfStock
                  ? Colors.redAccent
                  : item.isLowStock
                      ? const Color(0xFFFFB300)
                      : const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 14),

          // Name, Category & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121418),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (item.isLowStock && !item.isOutOfStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('⚠️ LOW STOCK (Restock Soon)', style: TextStyle(color: Color(0xFFFFB300), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                if (item.isOutOfStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('❌ OUT OF STOCK', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // Action buttons and +/- Counter
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Increment / Decrement Counter
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF121418),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2C3240)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16, color: Colors.white70),
                      onPressed: item.quantity > 0
                          ? () => stockRepo.updateStockQuantity(item.id, item.quantity - 1)
                          : null,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          color: item.quantity == 0
                              ? Colors.redAccent
                              : item.isLowStock
                                  ? const Color(0xFFFFB300)
                                  : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFFFF6B00)),
                      onPressed: () => stockRepo.updateStockQuantity(item.id, item.quantity + 1),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white54),
                      onPressed: onEdit,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      tooltip: 'Edit Stock Item',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                      onPressed: onDelete,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      tooltip: 'Delete Stock Item',
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
