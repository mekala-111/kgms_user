import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/get_productbooking.dart';
import 'package:kgms_user/providers/getproduct_provider.dart';
import 'package:kgms_user/providers/loader.dart';
import '../colors/colors.dart';
import 'product_ordertracking.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  @override
 void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final bookingState = ref.read(getproductProvider);
    if (bookingState.data == null || bookingState.data!.isEmpty) {
      ref.read(getproductProvider.notifier).getuserproduct();
    }
  });
}


 Future<void> _refreshBookings() async {
  ref.read(getproductProvider.notifier).reset(); // Clear cache
  await ref.read(getproductProvider.notifier).getuserproduct();
}


  int getCurrentStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 1;
      case 'confirmed':
        return 2;
      case 'startdelivery':
        return 3;
      case 'completed':
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(getproductProvider);
    final isLoading = ref.watch(loadingProvider);
    final bookingData = bookingState.data;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [KGMS.kgmsTeal, KGMS.primaryBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'My Orders',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Container(
        color: KGMS.kgmsWhite,
        child: RefreshIndicator(
          onRefresh: _refreshBookings,
          color: KGMS.primaryBlue,
          backgroundColor: Colors.white,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: KGMS.primaryBlue,
                    strokeWidth: 3,
                  ),
                )
              : bookingData == null
              ? _buildErrorState()
              : bookingData.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookingData.length,
                  itemBuilder: (context, index) {
                    final booking = bookingData[index];
                    return _buildBookingCard(context, booking);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KGMS.lightBlue,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: KGMS.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Orders Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: KGMS.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You haven\'t placed any orders yet. Start shopping to see your orders here!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: KGMS.secondaryText),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [KGMS.primaryBlue, KGMS.kgmsTeal],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to products/shop
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: KGMS.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please try again later',
              style: TextStyle(fontSize: 14, color: KGMS.secondaryText),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [KGMS.primaryBlue, KGMS.kgmsTeal],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: _refreshBookings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Data booking) {
    String productNames =
        booking.productIds?.map((p) => p.productName ?? 'Unknown').join(', ') ??
        'Unknown Product';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      shadowColor: KGMS.primaryBlue.withValues(alpha: 0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, KGMS.lightBlue.withValues(alpha: 0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: KGMS.primaryBlue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KGMS.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productNames,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: KGMS.primaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: KGMS.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Order Date: ${booking.createdAt ?? 'Unknown'}',
                              style: const TextStyle(
                                color: KGMS.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    booking.productIds?.first.bookingStatus ?? '',
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(
                      booking.productIds?.first.bookingStatus ?? '',
                    ),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(
                        booking.productIds?.first.bookingStatus ?? '',
                      ),
                      size: 16,
                      color: _getStatusColor(
                        booking.productIds?.first.bookingStatus ?? '',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusDisplayText(
                        booking.productIds?.first.bookingStatus ?? '',
                      ),
                      style: TextStyle(
                        color: _getStatusColor(
                          booking.productIds?.first.bookingStatus ?? '',
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: KGMS.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.currency_rupee_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        Text(
                          booking.totalPrice?.toStringAsFixed(2) ?? '0.00',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [KGMS.kgmsTeal, KGMS.primaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: KGMS.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingPage(
                              bookingId: booking.sId ?? '',
                              bookingDate: booking.createdAt ?? '',
                              totalPrice: booking.totalPrice ?? 0.0,
                              type: booking.type ?? '',
                              paidPrice: booking.paidPrice ?? 0,
                              otp: booking.otp ?? '',
                              products:
                                  booking.productIds?.map((product) {
                                    return BookedProduct(
                                      productId: product.sId ?? '',
                                      name: product.productName ?? '',
                                      price: product.price?.toDouble() ?? 0.0,
                                      quantity: product.quantity ?? 0,
                                      bookingStatus:
                                          product.bookingStatus ?? '',
                                      currentStep: getCurrentStep(
                                        product.bookingStatus ?? '',
                                      ),
                                      userPrice: product.userPrice ?? 0.0,
                                      distributorid:
                                          product.distributorId?.sId ?? '',
                                    );
                                  }).toList() ??
                                  [],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return KGMS.primaryBlue;
      case 'startdelivery':
        return KGMS.kgmsTeal;
      case 'completed':
        return KGMS.primaryGreen;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'startdelivery':
        return Icons.local_shipping_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'ORDER PLACED';
      case 'confirmed':
        return 'CONFIRMED';
      case 'startdelivery':
        return 'OUT FOR DELIVERY';
      case 'completed':
        return 'DELIVERED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return 'PENDING';
    }
  }
}
