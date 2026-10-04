import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Thin wrapper around razorpay_flutter so the rest of the app never
/// touches the SDK directly.
///
/// Setup required (not included here — coordinate with whoever owns
/// secrets/config):
///   1. Add `razorpay_flutter: ^1.3.7` (or latest) to pubspec.yaml.
///   2. Put the Razorpay key in core/config (Person A), not hardcoded here.
///   3. Android: minSdkVersion 19+; iOS: add camera/photo usage strings
///      if UPI QR flows are enabled.
class PaymentService {
  final Razorpay _razorpay = Razorpay();

  void init({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    void Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    if (onExternalWallet != null) {
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
  }

  /// [amountInRupees] is converted to paise internally (Razorpay expects
  /// the smallest currency unit).
  void openCheckout({
    required String razorpayKey,
    required String orderId,
    required double amountInRupees,
    required String studentName,
    required String studentEmail,
    required String studentPhone,
  }) {
    final options = {
      'key': razorpayKey,
      'amount': (amountInRupees * 100).round(),
      'currency': 'INR',
      'name': 'CanteenCrave',
      'description': 'Order #$orderId',
      'prefill': {
        'contact': studentPhone,
        'email': studentEmail,
        'name': studentName,
      },
      'notes': {'order_id': orderId},
    };
    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}