import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../models/flash_sale_model.dart';
import '../../../repositories/vendor_repository.dart';

class UnpickedOrderFlashModal extends StatefulWidget {
  final OrderModel order;
  final String vendorId;
  final VoidCallback? onSuccess;

  const UnpickedOrderFlashModal({
    super.key,
    required this.order,
    required this.vendorId,
    this.onSuccess,
  });

  @override
  State<UnpickedOrderFlashModal> createState() => _UnpickedOrderFlashModalState();
}

class _UnpickedOrderFlashModalState extends State<UnpickedOrderFlashModal> {
  int _selectedDiscount = 40;
  int _selectedExpiryMinutes = 30;
  bool _isLoading = false;
  final _vendorRepository = VendorRepository();

  Future<void> _publishFlashSale() async {
    setState(() => _isLoading = true);

    try {
      // Create flash sales for the items in the unpicked order
      for (final item in widget.order.items) {
        final flashSale = FlashSaleModel(
          id: '',
          orderId: widget.order.id,
          itemId: item.itemId,
          itemName: item.name,
          imageUrl: item.imageUrl,
          originalPrice: item.price,
          discountPercent: _selectedDiscount,
          campusId: widget.order.campusId,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(minutes: _selectedExpiryMinutes)),
          status: FlashSaleStatus.active,
        );

        await _vendorRepository.createFlashSale(flashSale);
      }

      // Update order status to uncollected
      await _vendorRepository.updateOrderStatus(
        widget.order.id,
        OrderStatus.uncollected,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ Flash Sale Activated & broadcast to students!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E222A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flash_on, color: Color(0xFFFFB300), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turn into Flash Sale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Broadcast uncollected items with discount',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF121418),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.order.items.map((it) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${it.quantity}x ${it.name}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '₹${(it.price * (1 - _selectedDiscount / 100)).toStringAsFixed(0)} (was ₹${it.price.toStringAsFixed(0)})',
                        style: const TextStyle(
                          color: Color(0xFFFFB300),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Select Flash Discount %',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [20, 30, 40, 50, 70].map((disc) {
              final isSel = _selectedDiscount == disc;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDiscount = disc),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFF6B00) : const Color(0xFF2C3240),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$disc%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Flash Sale Expiry Timer',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [15, 30, 45, 60].map((mins) {
              final isSel = _selectedExpiryMinutes == mins;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedExpiryMinutes = mins),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFFB300) : const Color(0xFF2C3240),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$mins m',
                        style: TextStyle(
                          color: isSel ? Colors.black : Colors.white,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _publishFlashSale,
            icon: const Icon(Icons.bolt, color: Colors.black),
            label: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text(
                    'Publish Flash Sale Now',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
