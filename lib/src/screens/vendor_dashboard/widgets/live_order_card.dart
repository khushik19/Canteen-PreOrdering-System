import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/order_model.dart';
import '../../../repositories/vendor_repository.dart';
import 'order_status_badge.dart';
import 'unpicked_order_flash_modal.dart';

class LiveOrderCard extends StatefulWidget {
  final OrderModel order;
  final String vendorId;
  final VoidCallback? onStatusChanged;

  const LiveOrderCard({
    super.key,
    required this.order,
    required this.vendorId,
    this.onStatusChanged,
  });

  @override
  State<LiveOrderCard> createState() => _LiveOrderCardState();
}

class _LiveOrderCardState extends State<LiveOrderCard> {
  final _vendorRepository = VendorRepository();
  final _otpController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String _getElapsedTimeString() {
    final diff = DateTime.now().difference(widget.order.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ${diff.inMinutes % 60}m ago';
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    setState(() => _isProcessing = true);
    try {
      await _vendorRepository.updateOrderStatus(widget.order.id, newStatus);
      widget.onStatusChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showOtpVerificationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E222A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Verify Student Pickup OTP',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask student for the 4-digit pickup code shown on their app.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFF6B00),
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF121418),
                hintText: '••••',
                hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 8),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await _vendorRepository.verifyAndCompleteOrder(
                orderId: widget.order.id,
                inputOtp: _otpController.text,
                actualOtp: widget.order.orderOtp,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Order Completed & Handed Over!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                  widget.onStatusChanged?.call();
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Invalid OTP. Please check with customer.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify & Complete'),
          ),
        ],
      ),
    );
  }

  void _openFlashSaleModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnpickedOrderFlashModal(
        order: widget.order,
        vendorId: widget.vendorId,
        onSuccess: widget.onStatusChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('hh:mm a').format(widget.order.createdAt);
    final elapsed = _getElapsedTimeString();
    final isStaleReady = widget.order.status == OrderStatus.ready &&
        DateTime.now().difference(widget.order.updatedAt).inMinutes >= 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.order.status == OrderStatus.placed
              ? const Color(0xFF3B82F6)
              : isStaleReady
                  ? const Color(0xFFFFB300)
                  : const Color(0xFF2C3240),
          width: widget.order.status == OrderStatus.placed || isStaleReady ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order ID, Time, Elapsed, Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '#${widget.order.id.length > 6 ? widget.order.id.substring(0, 6).toUpperCase() : widget.order.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121418),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$formattedTime ($elapsed)',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                      ),
                    ),
                  ],
                ),
                OrderStatusBadge(status: widget.order.status),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Name & Estimated Prep
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Color(0xFFFF6B00)),
                const SizedBox(width: 6),
                Text(
                  widget.order.userName,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (widget.order.userPhone.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text('(${widget.order.userPhone})', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
                const Spacer(),
                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFFFB300)),
                const SizedBox(width: 4),
                Text(
                  '${widget.order.maxCookingTimeMinutes}m prep',
                  style: const TextStyle(color: Color(0xFFFFB300), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            // Stale unpicked warning banner
            if (isStaleReady) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB300), size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Food ready >15m without pickup! Tap Flash Sale to avoid waste.',
                        style: TextStyle(color: Color(0xFFFFB300), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(color: Color(0xFF2C3240), height: 20),

            // Items List
            Column(
              children: widget.order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121418),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Text(
                        '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Total Amount and Payment status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.order.paymentStatus.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121418),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF2C3240)),
                      ),
                      child: Text(
                        'OTP: ${widget.order.orderOtp}',
                        style: const TextStyle(
                          color: Color(0xFFFFB300),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Total: ₹${widget.order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Interactive Actions Bar
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isProcessing) {
      return const Center(
        child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B00))),
      );
    }

    switch (widget.order.status) {
      case OrderStatus.placed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _updateStatus(OrderStatus.cancelled),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(OrderStatus.accepted),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Accept Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.accepted:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus(OrderStatus.preparing),
            icon: const Icon(Icons.soup_kitchen, size: 18),
            label: const Text('Start Preparing in Kitchen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        );

      case OrderStatus.preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus(OrderStatus.ready),
            icon: const Icon(Icons.notifications_active, size: 18),
            label: const Text('Mark Food Ready for Pickup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        );

      case OrderStatus.ready:
        return Row(
          children: [
            IconButton(
              onPressed: _openFlashSaleModal,
              tooltip: 'Push to Flash Sale',
              icon: const Icon(Icons.flash_on, color: Color(0xFFFFB300)),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300).withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showOtpVerificationDialog,
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('Verify OTP & Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.completed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF121418),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '✓ Handed over to student',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        );

      case OrderStatus.uncollected:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '⚡ Converted to Active Flash Sale',
              style: TextStyle(color: Color(0xFFFFB300), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        );

      case OrderStatus.cancelled:
        return const SizedBox.shrink();
    }
  }
}
