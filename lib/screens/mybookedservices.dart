import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/providers/servicebooking_provider.dart';
import 'package:kgms_user/screens/service_ordertracing.dart';

import '../colors/colors.dart';

class MyServicesPage extends ConsumerStatefulWidget {
  const MyServicesPage({super.key});

  @override
  ConsumerState<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends ConsumerState<MyServicesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(getserviceProvider.notifier).getUserBookedServices(),
    );
  }

  Future<void> _cancelBooking(BuildContext context, String? bookingId) async {
    if (bookingId == null) return;

    final bool confirmCancel = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: KGMS.cardBackground,
          title: const Text(
            "Cancel Booking",
            style: TextStyle(color: KGMS.primaryText),
          ),
          content: const Text(
            "Are you sure you want to cancel this service booking?",
            style: TextStyle(color: KGMS.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                "No",
                style: TextStyle(color: KGMS.secondaryText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Yes", style: TextStyle(color: KGMS.errorRed)),
            ),
          ],
        );
      },
    );

    if (confirmCancel) {
      ref.read(getserviceProvider.notifier).cancelUserService(bookingId);
    }
  }

  // Separate method that handles the async operation
  /*  void _performCancellation(BuildContext context, String bookingId) {
    // Capture context-dependent objects before any async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    ref.read(getserviceProvider.notifier).cancelUserService(bookingId).then((success) {
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Service booking canceled successfully"),
            backgroundColor: KGMS.successGreen,
          ),
        );
        ref.read(getserviceProvider.notifier).getUserBookedServices();
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Failed to cancel service booking"),
            backgroundColor: KGMS.errorRed,
          ),
        );
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final bookedServicesState = ref.watch(getserviceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booked Services',
          style: TextStyle(color: KGMS.primaryText),
        ),
        backgroundColor: KGMS.kgmsWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KGMS.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: KGMS.surfaceGrey,
      body: bookedServicesState.data == null
          ? const Center(
              child: CircularProgressIndicator(color: KGMS.primaryBlue),
            )
          : bookedServicesState.data!.isEmpty
          ? const Center(
              child: Text(
                "No booked services found",
                style: TextStyle(color: KGMS.secondaryText),
              ),
            )
          : ListView.builder(
              itemCount: bookedServicesState.data!.length,
              itemBuilder: (context, index) {
                final service = bookedServicesState.data![index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  color: KGMS.cardBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.serviceIds![0].name ?? "Unknown Service",
                          style: const TextStyle(
                            color: KGMS.primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Price: ₹${service.serviceIds![0].price ?? 'N/A'}",
                          style: const TextStyle(color: KGMS.secondaryText),
                        ),
                        Text(
                          'Status: ${service.status}',
                          style: const TextStyle(color: KGMS.secondaryText),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServiceOrdertracing(
                                      bookingId: service.sId ?? 'Unknown',
                                      serviceName:
                                          service.serviceIds?.isNotEmpty == true
                                          ? service.serviceIds!.first.name ?? ''
                                          : '',
                                      bookingDate:
                                          service.createdAt ?? 'Unknown',
                                      status: service.status ?? 'Pending',
                                      servicedescription:
                                          service.serviceIds?.isNotEmpty == true
                                          ? service.serviceIds!.first.details ??
                                                ''
                                          : "",
                                      price:
                                          service.serviceIds?.isNotEmpty == true
                                          ? service.serviceIds!.first.price
                                                    ?.toDouble() ??
                                                0.0
                                          : 0.0,
                                      serviceEngineerId:
                                          service.serviceEngineerId ?? '',
                                      startOtp: service.startOtp ?? '',
                                      endOtp: service.endOtp ?? '',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KGMS.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                  horizontal: screenWidth * 0.05,
                                ),
                              ),
                              child: Text(
                                'View Details',
                                style: TextStyle(
                                  color: KGMS.primaryText,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _cancelBooking(context, service.sId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KGMS.errorRed.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: KGMS.errorRed),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
