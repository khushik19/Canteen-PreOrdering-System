import 'package:flutter/material.dart';
import '../../models/flash_sale_model.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/vendor_repository.dart';

class VendorFlashSaleScreen extends StatelessWidget {
  final String vendorId;
  final String campusId;

  const VendorFlashSaleScreen({
    super.key,
    required this.vendorId,
    this.campusId = 'Main Campus',
  });

  void _showCreateFlashSaleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateFlashSaleSheet(vendorId: vendorId, campusId: campusId),
    );
  }

  void _deleteFlashSale(BuildContext context, String flashSaleId, String itemName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E222A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Flash Sale?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "$itemName" from the active campus flash sales feed?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await VendorRepository().deleteFlashSale(flashSaleId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Flash sale ended'), backgroundColor: Colors.redAccent),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('End Sale', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222A),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Color(0xFFFFB300)),
            SizedBox(width: 8),
            Text(
              'Flash Sales & Surplus Deals',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateFlashSaleDialog(context),
        backgroundColor: const Color(0xFFFFB300),
        icon: const Icon(Icons.flash_on, color: Colors.black),
        label: const Text('New Flash Deal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<FlashSaleModel>>(
        stream: VendorRepository().streamFlashSales(campusId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
          }

          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flash_on, size: 50, color: Color(0xFFFFB300)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Flash Sales',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Broadcast uncollected orders or surplus daily food with instant discounts (20%-70% off) directly to students on campus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateFlashSaleDialog(context),
                      icon: const Icon(Icons.bolt, color: Colors.black),
                      label: const Text('Create 1st Flash Deal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sales.length,
            itemBuilder: (ctx, i) {
              final s = sales[i];
              final isExpired = s.isExpired;
              final isClaimed = s.status == FlashSaleStatus.claimed;
              final remainingMins = s.expiresAt.difference(DateTime.now()).inMinutes;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E222A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isClaimed
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : isExpired
                            ? Colors.redAccent.withValues(alpha: 0.3)
                            : const Color(0xFFFFB300).withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${s.discountPercent}%\nOFF',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFB300),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.itemName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '₹${s.discountedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${s.originalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isClaimed
                                ? '🎉 Claimed by student'
                                : isExpired
                                    ? '⏰ Expired'
                                    : '⚡ Active on Feed (${remainingMins > 0 ? "$remainingMins mins left" : "Expiring soon"})',
                            style: TextStyle(
                              color: isClaimed
                                  ? const Color(0xFF10B981)
                                  : isExpired
                                      ? Colors.redAccent
                                      : const Color(0xFFFFB300),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: () => _deleteFlashSale(context, s.id, s.itemName),
                      tooltip: 'End Sale',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CreateFlashSaleSheet extends StatefulWidget {
  final String vendorId;
  final String campusId;

  const _CreateFlashSaleSheet({required this.vendorId, required this.campusId});

  @override
  State<_CreateFlashSaleSheet> createState() => _CreateFlashSaleSheetState();
}

class _CreateFlashSaleSheetState extends State<_CreateFlashSaleSheet> {
  final _vendorRepository = VendorRepository();
  MenuItemModel? _selectedItem;
  int _discount = 40;
  int _minutes = 30;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_selectedItem == null) return;
    setState(() => _isLoading = true);

    try {
      final flash = FlashSaleModel(
        id: '',
        orderId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
        itemId: _selectedItem!.id,
        itemName: _selectedItem!.name,
        imageUrl: _selectedItem!.imageUrl,
        originalPrice: _selectedItem!.price,
        discountPercent: _discount,
        campusId: widget.campusId,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: _minutes)),
        status: FlashSaleStatus.active,
      );

      await _vendorRepository.createFlashSale(flash);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ Flash Sale Activated & Broadcast across Campus!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
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
              const Icon(Icons.flash_on, color: Color(0xFFFFB300)),
              const SizedBox(width: 8),
              const Text(
                'Create Campus Flash Sale',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Select menu item
          StreamBuilder<List<MenuItemModel>>(
            stream: _vendorRepository.streamMenuItems(widget.vendorId),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Text('Please add items to your menu first.', style: TextStyle(color: Colors.white60));
              }

              return DropdownButtonFormField<MenuItemModel>(
                value: _selectedItem,
                dropdownColor: const Color(0xFF121418),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Select Menu Dish / Snack',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF121418),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                items: items.map((it) {
                  return DropdownMenuItem(
                    value: it,
                    child: Text('${it.name} (₹${it.price.toStringAsFixed(0)})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedItem = val),
              );
            },
          ),
          const SizedBox(height: 16),

          // Discount Selector
          const Text('Flash Discount %', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [20, 30, 40, 50, 70].map((d) {
              final isSel = _discount == d;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _discount = d),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFF6B00) : const Color(0xFF121418),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$d%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Expiry Timer Selector
          const Text('Flash Deal Expiry Timer', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [15, 30, 45, 60].map((m) {
              final isSel = _minutes == m;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _minutes = m),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFFB300) : const Color(0xFF121418),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$m mins',
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
            onPressed: (_selectedItem == null || _isLoading) ? null : _submit,
            icon: const Icon(Icons.bolt, color: Colors.black),
            label: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text('Broadcast Flash Deal Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
