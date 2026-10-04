enum PaymentStatus { pending, success, failed }

class PaymentModel {
  final String orderId;
  final double amount;
  PaymentStatus status;
  String? razorpayPaymentId;
  String? failureReason;

  PaymentModel({
    required this.orderId,
    required this.amount,
    this.status = PaymentStatus.pending,
    this.razorpayPaymentId,
    this.failureReason,
  });
}