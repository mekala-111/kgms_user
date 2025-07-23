import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/service_engineer_model.dart';
import 'package:kgms_user/providers/service_engineer.dart';
import '../colors/colors.dart';
import '../providers/servicebooking_provider.dart';

class ServiceOrdertracing extends ConsumerStatefulWidget {
  final String bookingId;
  final String serviceName;
  final String bookingDate;
  final String status;
  final String servicedescription;
  final double price;
  final String serviceEngineerId;
  final String startOtp;
  final String endOtp;

  const ServiceOrdertracing({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.bookingDate,
    required this.status,
    required this.servicedescription,
    required this.price,
    required this.serviceEngineerId,
    required this.startOtp,
    required this.endOtp,
  });

  @override
  ServiceOrderTrackingPageState createState() =>
      ServiceOrderTrackingPageState();
}

class ServiceOrderTrackingPageState extends ConsumerState<ServiceOrdertracing> {
  int currentStep = 1;

  @override
  void initState() {
    super.initState();
    _updateOrderStatus();
    Future.microtask(
      () => ref.read(serviceEngineer.notifier).getServiceengineers(),
    );
  }

  void _updateOrderStatus() {
    setState(() {
      if (widget.status.toLowerCase() == "confirmed") {
        currentStep = 2;
      } else if (widget.status.toLowerCase() == "servicestarted") {
        currentStep = 3;
      } else if (widget.status.toLowerCase() == "servicecompleted") {
        currentStep = 4;
      } else {
        currentStep = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String orderStatus = currentStep == 1
        ? "Booked..."
        : currentStep == 2
        ? "In Progress..."
        : currentStep == 3
        ? "Service Started..."
        : "Service Completed...";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KGMS.kgmsWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KGMS.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Service Tracking',
          style: TextStyle(color: KGMS.primaryText),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: KGMS.primaryText),
            onPressed: () {
              // Notification functionality
            },
          ),
        ],
      ),
      backgroundColor: KGMS.surfaceGrey,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service is $orderStatus',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: KGMS.primaryText,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Step Progress Bar
              Row(
                children: [
                  _buildStep(
                    screenWidth,
                    screenHeight,
                    1,
                    "Booked",
                    currentStep >= 1,
                  ),
                  _buildStepDivider(screenWidth, currentStep >= 2),
                  _buildStep(
                    screenWidth,
                    screenHeight,
                    2,
                    "In Progress",
                    currentStep >= 2,
                  ),
                  _buildStepDivider(screenWidth, currentStep >= 3),
                  _buildStep(
                    screenWidth,
                    screenHeight,
                    3,
                    "Service Started",
                    currentStep >= 3,
                  ),
                  _buildStepDivider(screenWidth, currentStep >= 4),
                  _buildStep(
                    screenWidth,
                    screenHeight,
                    4,
                    "Completed",
                    currentStep >= 4,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),

              // Service Details Card
              Card(
                color: KGMS.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service ID: ${widget.bookingId}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: KGMS.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Service: ${widget.serviceName}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: KGMS.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Description: ${widget.servicedescription}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: KGMS.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹ ${widget.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: KGMS.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${widget.bookingDate}',
                        style: TextStyle(
                          color: KGMS.secondaryText,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // OTP Information Card
              Card(
                color: KGMS.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service OTP Information',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: KGMS.primaryText,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Start OTP: ${widget.startOtp}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: KGMS.primaryText,
                            ),
                          ),
                          Text(
                            'End OTP: ${widget.endOtp}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: KGMS.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Service Engineer Details
              const Text(
                'Service Engineer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: KGMS.primaryText,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Consumer(
                builder: (context, ref, child) {
                  final engineerState = ref.watch(serviceEngineer);
                  final engineers = engineerState.data;

                  if (widget.serviceEngineerId.isEmpty) {
                    return Card(
                      color: KGMS.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "Service Engineer will be assigned soon.",
                            style: TextStyle(color: KGMS.primaryText),
                          ),
                        ),
                      ),
                    );
                  }

                  if (engineers == null || engineers.isEmpty) {
                    return Card(
                      color: KGMS.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "No service engineers available.",
                            style: TextStyle(color: KGMS.secondaryText),
                          ),
                        ),
                      ),
                    );
                  }

                  Data? assignedEngineer;
                  try {
                    assignedEngineer = engineers.firstWhere(
                      (engineer) => engineer.sId == widget.serviceEngineerId,
                    );
                  } catch (e) {
                    assignedEngineer = null;
                  }

                  if (assignedEngineer == null) {
                    return Card(
                      color: KGMS.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "Assigned Service Engineer not found.",
                            style: TextStyle(color: KGMS.errorRed),
                          ),
                        ),
                      ),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: KGMS.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: KGMS.lightBlue,
                                backgroundImage:
                                    assignedEngineer.serviceEngineerImage !=
                                            null &&
                                        assignedEngineer
                                            .serviceEngineerImage!
                                            .isNotEmpty
                                    ? NetworkImage(
                                        assignedEngineer
                                            .serviceEngineerImage!
                                            .first,
                                      )
                                    : null,
                                child:
                                    assignedEngineer.serviceEngineerImage ==
                                            null ||
                                        assignedEngineer
                                            .serviceEngineerImage!
                                            .isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: KGMS.primaryText,
                                        size: 30,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  assignedEngineer.name ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: KGMS.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "📱 Mobile: ${assignedEngineer.mobile ?? 'N/A'}",
                            style: const TextStyle(color: KGMS.secondaryText),
                          ),
                          Text(
                            "📧 Email: ${assignedEngineer.email ?? 'N/A'}",
                            style: const TextStyle(color: KGMS.secondaryText),
                          ),
                          Text(
                            "📍 Address: ${assignedEngineer.address ?? 'N/A'}",
                            style: const TextStyle(color: KGMS.secondaryText),
                          ),
                          Text(
                            "🛠️ Experience: ${assignedEngineer.experience ?? 0} yrs",
                            style: const TextStyle(color: KGMS.secondaryText),
                          ),
                          if (assignedEngineer.description != null &&
                              assignedEngineer.description!.isNotEmpty)
                            Text(
                              "📝 Description: ${assignedEngineer.description}",
                              style: const TextStyle(color: KGMS.secondaryText),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
    double screenWidth,
    double screenHeight,
    int step,
    String title,
    bool isActive,
  ) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.1,
          height: screenHeight * 0.01,
          color: isActive ? KGMS.primaryBlue : KGMS.lightText,
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? KGMS.primaryBlue : KGMS.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(double screenWidth, bool isActive) {
    return Expanded(
      child: Container(
        height: screenWidth * 0.005,
        color: isActive ? KGMS.primaryBlue : KGMS.lightText,
      ),
    );
  }
}

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

  Future<void> _cancelBooking(String? bookingId) async {
    if (bookingId == null || !mounted) return;

    final bool confirmCancel =
        await showDialog<bool>(
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
                  child: const Text(
                    "Yes",
                    style: TextStyle(color: KGMS.errorRed),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Handle null case when dialog is dismissed

    if (!confirmCancel || !mounted) return;

    try {
      final success = await ref
          .read(getserviceProvider.notifier)
          .cancelUserService(bookingId);

      // Check if widget is still mounted before using context
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Service booking canceled successfully"),
            backgroundColor: KGMS.successGreen,
          ),
        );
        ref.read(getserviceProvider.notifier).getUserBookedServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to cancel service booking"),
            backgroundColor: KGMS.errorRed,
          ),
        );
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('Error canceling booking: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error canceling booking. Please try again."),
          backgroundColor: KGMS.errorRed,
        ),
      );
    }
  }

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
                              onPressed: () => _cancelBooking(service.sId),
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
