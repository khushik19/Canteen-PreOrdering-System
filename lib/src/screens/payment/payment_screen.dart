import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../repositories/payment_repository.dart';
import '../../services/payment_service.dart';
import '../cart/cart_theme.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel order;
  // TODO: pull real student details from the auth/profile state (Person A/D)
  // instead of passing placeholders in.
  final String studentName;
  final String studentEmail;
  final String studentPhone;

  const PaymentScreen({
    super.key,
    required this.order,
    required this.studentName,
    required this.studentEmail,
    required this.studentPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final PaymentRepository _paymentRepository = PaymentRepository();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentService.init(
      onSuccess: _handleSuccess,
      onError: _handleError,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _startPayment() {
    setState(() => _isProcessing = true);
    _paymentService.openCheckout(
      // TODO: move this key into core/config, never hardcode it in a
      // shipped build.
      razorpayKey: 'YOUR_RAZORPAY_KEY_ID',
      orderId: widget.order.id,
      amountInRupees: widget.order.total,
      studentName: widget.studentName,
      studentEmail: widget.studentEmail,
      studentPhone: widget.studentPhone,
    );
  }

  Future<void> _handleSuccess(PaymentSuccessResponse response) async {
    final payment = PaymentModel(
      orderId: widget.order.id,
      amount: widget.order.total,
      status: PaymentStatus.success,
      razorpayPaymentId: response.paymentId,
    );
    await _paymentRepository.recordPaymentSuccess(payment);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    Navigator.of(context).pop(payment);
  }

  Future<void> _handleError(PaymentFailureResponse response) async {
    final payment = PaymentModel(
      orderId: widget.order.id,
      amount: widget.order.total,
      status: PaymentStatus.failed,
      failureReason: response.message,
    );
    await _paymentRepository.recordPaymentFailure(payment);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message ?? 'Payment failed. Try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CartColors.background,
      appBar: AppBar(
        backgroundColor: CartColors.background,
        elevation: 0,
        title: const Text('Payment', style: TextStyle(color: CartColors.textPrimary)),
        iconTheme: const IconThemeData(color: CartColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: CartColors.glassDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(CartRadii.button),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _startPayment,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Pay ₹${widget.order.total.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CartColors.cardSurface,
        borderRadius: BorderRadius.circular(CartRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: CartColors.textPrimary)),
          const SizedBox(height: 12),
          for (final item in widget.order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.quantity > 1 ? '${item.name} × ${item.quantity}' : item.name,
                      style: const TextStyle(fontSize: 13.5, color: CartColors.textPrimary),
                    ),
                  ),
                  Text('₹${item.lineTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13.5, color: CartColors.textPrimary)),
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
                child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              Text('₹${widget.order.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.order.isAsap
                ? 'Pickup: ASAP'
                : 'Pickup: ${_formatDateTime(widget.order.pickupTime)}',
            style: const TextStyle(fontSize: 12.5, color: CartColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}