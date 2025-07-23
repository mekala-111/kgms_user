import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../colors/colors.dart';

class RazorpayPaymentPage extends StatefulWidget {
  final double amount;
  final String contact;
  final String email;
  final VoidCallback onSuccess;

  const RazorpayPaymentPage({
    super.key,
    required this.amount,
    required this.contact,
    required this.email,
    required this.onSuccess,
  });

  @override
  State<RazorpayPaymentPage> createState() => _RazorpayPaymentPageState();
}

class _RazorpayPaymentPageState extends State<RazorpayPaymentPage>
    with TickerProviderStateMixin {
  late Razorpay _razorpay;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  bool _isProcessing = true;
  String _statusMessage = "Initializing secure payment...";

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.repeat(reverse: true);

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternal);

    // Start payment after a short delay for better UX
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _statusMessage = "Opening secure payment gateway...";
        });
        _startPayment();
      }
    });
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_live_6tvrYJlTwFFGiV',
      'amount': (widget.amount * 100).toInt(),
      'name': 'KGMS',
      'description': 'KGMS Product Booking Payment',
      'prefill': {
        'contact': widget.contact,
        'email': widget.email,
      },
      'theme': {
        'color': '#1B73E8',
      },
      'notes': {
        'payment_for': 'KGMS_products',
        'customer_type': 'KGMS_user',
      },
    };

    try {
      setState(() {
        _statusMessage = "Processing payment securely...";
      });
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _statusMessage = "Payment initialization failed";
        _isProcessing = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _statusMessage = "Payment successful! Processing...";
      _isProcessing = false;
    });

    // Stop pulse animation and show success animation
    _animationController.stop();
    _animationController.reset();
    _animationController.forward();

    // Show success message briefly before calling onSuccess
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      widget.onSuccess();
      Navigator.pop(context);
    }
  }

  void _handleError(PaymentFailureResponse response) {
    setState(() {
      _statusMessage = "Payment failed. Please try again.";
      _isProcessing = false;
    });

    _animationController.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('❌ Payment failed'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _handleExternal(ExternalWalletResponse response) {
    setState(() {
      _statusMessage = "Redirecting to external wallet...";
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              KGMS.kgmsWhite,
              KGMS.lightBlue,
              KGMS.primaryBlue.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // KGMS logo/icon section
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [KGMS.primaryBlue, KGMS.kgmsTeal],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: KGMS.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // GoMed branding
                  const Text(
                    'KGMS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: KGMS.primaryBlue,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Secure KGMS Payment',
                    style: TextStyle(
                      fontSize: 16,
                      color: KGMS.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Payment amount display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [KGMS.lightBlue, Colors.white],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: KGMS.primaryBlue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: KGMS.primaryBlue.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.currency_rupee_rounded,
                            color: KGMS.primaryGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          widget.amount.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Loading indicator
                  if (_isProcessing) ...[
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [KGMS.kgmsTeal, KGMS.primaryBlue],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    // Success/Error icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _statusMessage.contains('successful')
                            ? KGMS.primaryGreen
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _statusMessage.contains('successful')
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Status message
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: KGMS.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Security badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSecurityBadge(Icons.security_rounded, 'Secure'),
                      const SizedBox(width: 20),
                      _buildSecurityBadge(Icons.verified_rounded, 'Verified'),
                      const SizedBox(width: 20),
                      _buildSecurityBadge(Icons.lock_rounded, 'Encrypted'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KGMS.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: KGMS.primaryGreen, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: KGMS.primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
