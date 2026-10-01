import 'package:flutter/material.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/flash_sale_model.dart';
import '../flash_sale_controller.dart';

class FlashSaleClaimSheet extends StatefulWidget {
  final FlashSaleModel sale;
  final String currentUserId;

  const FlashSaleClaimSheet({super.key, required this.sale, required this.currentUserId});

  @override
  State<FlashSaleClaimSheet> createState() => _FlashSaleClaimSheetState();
}

class _FlashSaleClaimSheetState extends State<FlashSaleClaimSheet> {
  bool _isClaiming = false;

  Future<void> _handleClaim() async {
    setState(() => _isClaiming = true);

    final controller = FlashSaleController();
    final success = await controller.claim(widget.sale.id, widget.currentUserId);

    if (!mounted) return;
    setState(() => _isClaiming = false);

    if (success) {
      Navigator.of(context).pop();
      // TODO (coordinate with Person B): trigger checkout/payment with the
      // discounted price, reusing the existing order/payment pipeline.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claimed! Proceed to payment.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sorry, this item was just claimed by someone else.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              sale.imageUrl ?? 'https://placehold.co/400x250',
              height: 160, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160, color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(sale.itemName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('₹${sale.discountedPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(width: 10),
              Text('₹${sale.originalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: Colors.grey)),
              const SizedBox(width: 10),
              StatusBadge.discount(sale.discountPercent),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Expires at ${sale.expiresAt.hour.toString().padLeft(2, '0')}:${sale.expiresAt.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Claim This Item', isLoading: _isClaiming, onPressed: _handleClaim, width: double.infinity),
        ],
      ),
    );
  }
}