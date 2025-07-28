import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../colors/colors.dart';
import '../providers/getproduct_provider.dart';

class BookedProduct {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String bookingStatus;
  final int currentStep;
  final double userPrice;
  final String distributorid;

  BookedProduct(
      {required this.productId,
      required this.name,
      required this.price,
      required this.quantity,
      required this.bookingStatus,
      required this.currentStep,
      required this.userPrice,
      required this.distributorid});
}

class OrderTrackingPage extends ConsumerStatefulWidget {
  final String bookingId;
  final String bookingDate;
  final double totalPrice;
  final String type;
  final double paidPrice;
  final String otp;
  final List<BookedProduct> products;

  const OrderTrackingPage({
    super.key,
    required this.bookingId,
    required this.bookingDate,
    required this.totalPrice,
    required this.type,
    required this.paidPrice,
    required this.otp,
    required this.products,
  });

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final otp = widget.otp;
    final totalPrice = widget.totalPrice;
    final paidPrice = widget.paidPrice;
    final remain = totalPrice - paidPrice;

    // Fixed: Changed to get cancelled products correctly
    final cancelledProducts = widget.products
        .where((p) => p.bookingStatus.toLowerCase() == "cancelled")
        .toList();

    final cancelledPrice =
        cancelledProducts.fold(0.0, (sum, p) => sum + p.price * p.quantity);
    final remainingPay = remain - cancelledPrice;
    String orderid = _truncateText(widget.bookingId , 19);

    return Scaffold(
      backgroundColor: KGMS.kgmsWhite,
      appBar: AppBar(
        backgroundColor: KGMS.kgmsTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              KGMS.lightBlue.withValues(alpha: 0.3), // Fixed: using withOpacity
              KGMS.kgmsWhite,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KGMS.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), // Fixed
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: KGMS.kgmsTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order ID: $orderid',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: KGMS.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order Date: ${widget.bookingDate}',
                          style: const TextStyle(
                            color: KGMS.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.lock,
                          color: KGMS.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'OTP: $otp',
                          style: const TextStyle(
                            color: KGMS.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Products List
              Expanded(
                child: ListView.separated(
                  itemCount: widget.products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final product = widget.products[index];
                    return _buildProductCard(
                        context, product, screenWidth, screenHeight);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Price Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KGMS.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), // Fixed
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: KGMS.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(
                            fontSize: 14,
                            color: KGMS.secondaryText,
                          ),
                        ),
                        Text(
                          '₹${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paid Amount:',
                          style: TextStyle(
                            fontSize: 14,
                            color: KGMS.secondaryText,
                          ),
                        ),
                        Text(
                          '₹${paidPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: KGMS.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (widget.type.toLowerCase() == 'cod') ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remaining Payment:',
                            style: TextStyle(
                              fontSize: 14,
                              color: KGMS.secondaryText,
                            ),
                          ),
                          Text(
                            '₹${remainingPay.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: KGMS.errorRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Review Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to review screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KGMS.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.25,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Leave a Review',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 String _truncateText(String text, int maxLength) {
    return text.length > maxLength
        ? "${text.substring(0, maxLength)}..."
        : text;
  }

  Widget _buildProductCard(BuildContext context, BookedProduct product,
      double screenWidth, double screenHeight) {
    int currentStep = 0;
    final status = product.bookingStatus.toLowerCase().trim();

    switch (status) {
      case 'pending':
        currentStep = 0;
        break;
      case 'confirmed':
        currentStep = 1;
        break;
      case 'startdelivery':
        currentStep = 2;
        break;
      case 'completed':
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KGMS.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: product.bookingStatus.toLowerCase() == "cancelled"
              ? KGMS.errorRed.withValues(alpha: 0.3) // Fixed
              : KGMS.lightBlue.withValues(alpha: 0.5), // Fixed
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Fixed
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag, // Fixed: replaced Icons.KGMS_services
                color: KGMS.kgmsTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: KGMS.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price: ₹${product.userPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: KGMS.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${product.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: KGMS.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${widget.type}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: KGMS.lightText,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(product.bookingStatus)
                      .withValues(alpha: 0.1), // Fixed
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(product.bookingStatus),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(product.bookingStatus),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(product.bookingStatus),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (product.bookingStatus.toLowerCase() == "cancelled") ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KGMS.errorRed.withValues(alpha: 0.1), // Fixed
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: KGMS.errorRed.withValues(alpha: 0.3), // Fixed
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: KGMS.errorRed,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This product is cancelled. The refund amount will be credited in 2 to 3 working days.",
                      style: TextStyle(
                        color: KGMS.errorRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (widget.type.toLowerCase() == "cod")
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KGMS.lightBlue.withValues(alpha: 0.5), // Fixed
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Remaining Pay: ₹${(product.price * product.quantity).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: KGMS.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Progress Stepper
            Row(
              children: [
                _buildStep(
                    screenWidth, screenHeight, 1, "Booked", currentStep >= 0),
                _buildStepDivider(screenWidth, currentStep >= 1),
                _buildStep(screenWidth, screenHeight, 2, "Confirmed",
                    currentStep >= 1),
                _buildStepDivider(screenWidth, currentStep >= 2),
                _buildStep(screenWidth, screenHeight, 3, "Out for Delivery",
                    currentStep >= 2),
                _buildStepDivider(screenWidth, currentStep >= 3),
                _buildStep(screenWidth, screenHeight, 4, "Completed",
                    currentStep >= 3),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          if (product.bookingStatus.toLowerCase() == "pending" ||
              product.bookingStatus.toLowerCase() == "confirmed") ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(
                        "Cancel Product Booking",
                        style: TextStyle(color: KGMS.primaryText),
                      ),
                      content: const Text(
                        "Are you sure you want to cancel this product from the booking?",
                        style: TextStyle(color: KGMS.secondaryText),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(
                            "No",
                            style: TextStyle(color: KGMS.secondaryText),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KGMS.errorRed,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final success = await ref
                        .read(getproductProvider.notifier)
                        .cancelBooking(widget.bookingId, product.productId,
                            product.distributorid);

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Product booking canceled successfully'),
                          backgroundColor: KGMS.successGreen,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KGMS.errorRed,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text(
                  'Cancel Booking',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ] else if (product.bookingStatus.toLowerCase() ==
              "startdelivery") ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KGMS.warningOrange.withValues(alpha: 0.1), // Fixed
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: KGMS.warningOrange.withValues(alpha: 0.3), // Fixed
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: KGMS.warningOrange,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You can't cancel this booking because the product was shipped.",
                      style: TextStyle(
                        color: KGMS.warningOrange,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (product.bookingStatus.toLowerCase() == "completed") ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KGMS.successGreen.withValues(alpha: 0.1), // Fixed
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: KGMS.successGreen.withValues(alpha: 0.3), // Fixed
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: KGMS.successGreen,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Delivery completed.",
                    style: TextStyle(
                      color: KGMS.successGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return KGMS.warningOrange;
      case 'confirmed':
        return KGMS.primaryBlue;
      case 'startdelivery':
        return KGMS.accentTeal;
      case 'completed':
        return KGMS.successGreen;
      case 'cancelled':
        return KGMS.errorRed;
      default:
        return KGMS.lightText;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'startdelivery':
        return 'Shipping';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Widget _buildStep(double screenWidth, double screenHeight, int step,
      String title, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? KGMS.primaryBlue : KGMS.surfaceGrey,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? KGMS.primaryBlue : KGMS.lightText,
              width: 2,
            ),
          ),
          child: Center(
            child: isActive
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : KGMS.lightText,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? KGMS.primaryBlue : KGMS.lightText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepDivider(double screenWidth, bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? KGMS.primaryBlue : KGMS.lightText,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
