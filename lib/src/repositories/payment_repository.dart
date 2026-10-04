import '../models/payment_model.dart';

/// Stub until core/network (Person A) and the backend schema exist.
/// Swap the bodies for real Firebase/Supabase calls once those land —
/// the method signatures are the contract the rest of the app depends on.
class PaymentRepository {
  Future<void> recordPaymentSuccess(PaymentModel payment) async {
    // TODO: write to orders/{orderId} — set status, paymentId.
  }

  Future<void> recordPaymentFailure(PaymentModel payment) async {
    // TODO: log failure for reporting (Person C's vendor reports read this).
  }
}