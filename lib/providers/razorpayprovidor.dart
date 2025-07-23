import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

final razorpayProvider = StateNotifierProvider<RazorPayController, bool>((ref) {
  return RazorPayController(ref);
});

class RazorPayController extends StateNotifier<bool> {
  final Ref ref;
  late Razorpay _razorpay;

  RazorPayController(this.ref) : super(false) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required double amount,
    required String contact,
    required String email,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
  }) {
    var options = {
      'key': 'rzp_test_YourApiKeyHere', // replace with real key
      'amount': (amount * 100).toInt(),
      'name': 'Gomed',
      'description': 'Product Booking',
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _onSuccessCallback = onSuccess;
      _onFailureCallback = onFailure;
      _razorpay.open(options);
    } catch (e) {
      log('Razorpay Error: $e');
      onFailure();
    }
  }

  VoidCallback? _onSuccessCallback;
  VoidCallback? _onFailureCallback;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log("Payment Success: ${response.paymentId}");
    _onSuccessCallback?.call();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log("Payment Failed: ${response.message}");
    _onFailureCallback?.call();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log("External Wallet Selected: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
