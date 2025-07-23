import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kgms_user/main.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/providers/servicebooking_provider.dart';
import 'package:kgms_user/screens/razorpay_payment_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../colors/colors.dart';
import 'mybookedservices.dart';

class BookingStagePage extends ConsumerStatefulWidget {
  final String serviceId;
  final String productId;
  final int? serviceAmount;

  const BookingStagePage({
    super.key,
    required this.serviceId,
    required this.productId,
    required this.serviceAmount,
  });

  @override
  ConsumerState<BookingStagePage> createState() => _BookingStagePageState();
}

class _BookingStagePageState extends ConsumerState<BookingStagePage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String startOtp = generateOtp();
  String endOtp = generateOtp();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final userState = ref.read(userProvider);

      if (userState.data != null && userState.data!.isNotEmpty) {
        final user = userState.data!.first.user!;
        _addressController.text = user.address ?? 'No Address';

        // Fetch landmark (human-readable address from lat/lng)
        if (user.location != null && user.location!.latitude!.isNotEmpty) {
          try {
            double latitude = double.parse(user.location!.latitude!);
            double longitude = double.parse(user.location!.longitude!);

            List<Placemark> placemarks = await placemarkFromCoordinates(
              latitude,
              longitude,
            );
            if (placemarks.isNotEmpty && mounted) {
              Placemark place = placemarks.first;
              setState(() {
                _landmarkController.text =
                    "${place.street ?? 'Unknown Street'}, ${place.locality ?? 'Unknown City'}, ${place.country ?? 'Unknown Country'}";
              });
            }
          } on FormatException {
            // Handle invalid latitude/longitude format
            if (mounted) {
              setState(() {
                _landmarkController.text =
                    'Unable to parse location coordinates';
              });
            }
          } on Exception {
            // Handle geocoding errors (network issues, API limits, etc.)
            // For debugging
            if (mounted) {
              setState(() {
                _landmarkController.text = 'Unable to fetch location details';
              });
            }
          }
        }
      }
    } catch (e) {
      // Handle any other errors during user data loading
      // For debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: ${e.toString()}'),
            backgroundColor: KGMS.errorRed,
          ),
        );
      }
    } finally {
      // Ensure loading state is reset even if errors occur
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    String? newAddress = await _showAddressDialog();

    if (!mounted) return;

    if (newAddress != null && newAddress.isNotEmpty) {
      await prefs.setString('user_address', newAddress);

      if (mounted) {
        setState(() {
          _addressController.text = newAddress;
        });
      }
    }
  }

  Future<String?> _showAddressDialog() async {
    TextEditingController addressInput = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: KGMS.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Change Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: KGMS.primaryText,
            ),
          ),
          content: TextField(
            controller: addressInput,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter new address',
              hintStyle: const TextStyle(color: KGMS.lightText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: KGMS.secondaryText),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: KGMS.primaryBlue),
              ),
              filled: true,
              fillColor: KGMS.surfaceGrey,
            ),
            style: const TextStyle(color: KGMS.primaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: KGMS.secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, addressInput.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: KGMS.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: KGMS.kgmsWhite),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: KGMS.primaryBlue,
              onPrimary: KGMS.kgmsWhite,
              surface: KGMS.cardBackground,
              onSurface: KGMS.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to pick time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: KGMS.primaryBlue,
              onPrimary: KGMS.kgmsWhite,
              surface: KGMS.cardBackground,
              onSurface: KGMS.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KGMS.kgmsWhite,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KGMS.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Book Service',
          style: TextStyle(
            color: KGMS.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: KGMS.primaryText,
            ),
            onPressed: () {
              // Notification functionality
            },
          ),
        ],
      ),
      backgroundColor: KGMS.surfaceGrey,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: KGMS.primaryBlue),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Details Card
                  Card(
                    elevation: 2,
                    color: KGMS.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.home_repair_service,
                                color: KGMS.primaryBlue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Service Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: KGMS.primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Service ID: ${widget.serviceId}',
                            style: const TextStyle(color: KGMS.secondaryText),
                          ),
                          Text(
                            'Product ID: ${widget.productId}',
                            style: const TextStyle(color: KGMS.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Address Section
                  Card(
                    elevation: 2,
                    color: KGMS.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.location_on, color: KGMS.errorRed),
                                  SizedBox(width: 8),
                                  Text(
                                    'Service Address',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: KGMS.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: _changeAddress,
                                icon: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: KGMS.primaryBlue,
                                ),
                                label: const Text(
                                  'Change',
                                  style: TextStyle(color: KGMS.primaryBlue),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: KGMS.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _addressController,
                            maxLines: 2,
                            style: const TextStyle(color: KGMS.primaryText),
                            decoration: InputDecoration(
                              labelText: 'Your Address',
                              labelStyle: const TextStyle(
                                color: KGMS.secondaryText,
                              ),
                              hintText: 'Enter your complete address',
                              hintStyle: const TextStyle(color: KGMS.lightText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: KGMS.secondaryText,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: KGMS.primaryBlue,
                                ),
                              ),
                              filled: true,
                              fillColor: KGMS.surfaceGrey,
                              prefixIcon: const Icon(
                                Icons.home,
                                color: KGMS.secondaryText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _landmarkController,
                            style: const TextStyle(color: KGMS.primaryText),
                            decoration: InputDecoration(
                              labelText: 'Landmark',
                              labelStyle: const TextStyle(
                                color: KGMS.secondaryText,
                              ),
                              hintText: 'Enter nearby landmark',
                              hintStyle: const TextStyle(color: KGMS.lightText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: KGMS.secondaryText,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: KGMS.primaryBlue,
                                ),
                              ),
                              filled: true,
                              fillColor: KGMS.surfaceGrey,
                              prefixIcon: const Icon(
                                Icons.place,
                                color: KGMS.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Date & Time Section
                  Card(
                    elevation: 2,
                    color: KGMS.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.schedule, color: KGMS.primaryGreen),
                              SizedBox(width: 8),
                              Text(
                                'Schedule Service',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: KGMS.primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Date Selection
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: KGMS.secondaryText.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.calendar_today,
                                color: KGMS.primaryBlue,
                              ),
                              title: Text(
                                _selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat(
                                        'EEEE, MMM dd, yyyy',
                                      ).format(_selectedDate!),
                                style: TextStyle(
                                  fontWeight: _selectedDate == null
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: _selectedDate == null
                                      ? KGMS.lightText
                                      : KGMS.primaryText,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: KGMS.secondaryText,
                              ),
                              onTap: () => _selectDate(context),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Time Selection
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: KGMS.secondaryText.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.access_time,
                                color: KGMS.warningOrange,
                              ),
                              title: Text(
                                _selectedTime == null
                                    ? 'Select Time'
                                    : _selectedTime!.format(context),
                                style: TextStyle(
                                  fontWeight: _selectedTime == null
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: _selectedTime == null
                                      ? KGMS.lightText
                                      : KGMS.primaryText,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: KGMS.secondaryText,
                              ),
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Book Service Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isBookingValid() ? _bookService : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KGMS.primaryBlue,
                        disabledBackgroundColor: KGMS.lightText.withValues(
                          alpha: 0.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment,
                            color: _isBookingValid()
                                ? KGMS.kgmsWhite
                                : KGMS.lightText,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'BOOK SERVICE',
                            style: TextStyle(
                              color: _isBookingValid()
                                  ? KGMS.kgmsWhite
                                  : KGMS.lightText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
    );
  }

  bool _isBookingValid() {
    return _selectedDate != null &&
        _selectedTime != null &&
        _addressController.text.isNotEmpty &&
        _landmarkController.text.isNotEmpty;
  }

  Future<void> _bookService() async {
    if (!_isBookingValid()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields before proceeding.'),
          backgroundColor: KGMS.errorRed,
        ),
      );
      return;
    }

    final userState = ref.read(userProvider);

    if (userState.data != null && userState.data!.isNotEmpty) {
      final user = userState.data!.first.user;
      final userId = user?.sId;
      final address = _addressController.text;
      final contact = user?.mobile ?? '+919999999999';
      final email = user?.email ?? 'examplemail@gmail.com';

      String location = '';
      if (user?.location != null) {
        location = '${user!.location!.latitude},${user.location!.longitude}';
      }

      if (widget.serviceId.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one service'),
            backgroundColor: KGMS.errorRed,
          ),
        );
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      String formattedTime = _selectedTime!.format(context);

      if (!mounted) return;

      // Navigate to Razorpay payment page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RazorpayPaymentPage(
            amount: widget.serviceAmount!.toDouble(),
            contact: contact,
            email: email,
            onSuccess: () async {
              try {
                await ref
                    .read(getserviceProvider.notifier)
                    .addServices(
                      userId: userId,
                      serviceId: [widget.serviceId],
                      productId: widget.productId,
                      location: location,
                      address: address,
                      date: formattedDate,
                      time: formattedTime,
                      startOtp: startOtp,
                      endOtp: endOtp,
                    );

                // Check if the widget is still mounted before using context
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking successful!'),
                    backgroundColor: KGMS.successGreen,
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyServicesPage()),
                );
              } catch (error) {
                // Check if the widget is still mounted before using context
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to book service: $error'),
                    backgroundColor: KGMS.errorRed,
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }
}
