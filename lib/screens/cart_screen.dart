import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/main.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/providers/getproduct_provider.dart';
import 'package:kgms_user/screens/razorpay_payment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kgms_user/providers/products.dart';
import 'package:kgms_user/model/product.dart';
import "package:kgms_user/screens/products_screen.dart";
import 'package:geocoding/geocoding.dart';
import 'package:kgms_user/screens/address_edit_screen.dart';

import '../colors/colors.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => CartScreenState();
}

enum PaymentMethod { cod, online }

class CartScreenState extends ConsumerState<CartScreen> {
  List<String> cartItemKeys = [];
  List<Data> cartProducts = [];
  List<String> selectedCartItemKeys = [];
  Map<String, int> productQuantities = {};
  Map<String, bool> productSelections = {};
  PaymentMethod selectedMethod = PaymentMethod.online;
  String? add1;
  String? add2;
  double? latitude;
  double? longitude;
  String? userid;
  double? totalAmount;
  double? codAdvance;
  String locationAddress = "Fetching location...";

  String bookingOtp = generatebookingOtp();

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userState = ref.watch(userProvider);

      if (userState.data != null && userState.data!.isNotEmpty) {
        final user = userState.data![0].user;
        if (mounted) {
          setState(() {
            userid = userState.data![0].user!.sId;
            add1 = user!.address ?? prefs.getString('add1') ?? "No Address";
            latitude =
                double.tryParse(user.location?.latitude ?? "0.0") ??
                double.tryParse(prefs.getString('latitude') ?? "0.0");
            longitude =
                double.tryParse(user.location?.longitude ?? "0.0") ??
                double.tryParse(prefs.getString('longitude') ?? "0.0");
          });
        }

        if (latitude != null && longitude != null) {
          _getAddressFromCoordinates(latitude!, longitude!);
        }
      } else {
        if (mounted) {
          setState(() {
            add1 = prefs.getString('add1') ?? "No Address";
            latitude = double.tryParse(prefs.getString('latitude') ?? "0.0");
            longitude = double.tryParse(prefs.getString('longitude') ?? "0.0");
          });
        }

        if (latitude != null && longitude != null) {
          _getAddressFromCoordinates(latitude!, longitude!);
        }
      }
    } catch (e) {
      // Log error and handle gracefully
      debugPrint('Error loading address: $e');
      if (mounted) {
        setState(() {
          add1 = "Error loading address";
          locationAddress = "Could not fetch location";
        });
      }
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        setState(() {
          locationAddress =
              "${place.street}, ${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      if (mounted) {
        setState(() {
          locationAddress = "Could not fetch location";
        });
      }
    }
  }

  Future<void> _navigateToAddressEdit() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressEditScreen(
            currentAddress: add1,
            currentLatitude: latitude,
            currentLongitude: longitude,
            currentLocationAddress: locationAddress,
          ),
        ),
      );

      if (!mounted) return;

      if (result != null && result is Map<String, dynamic>) {
        bool hasChanges = result['hasChanges'] ?? false;

        if (hasChanges) {
          setState(() {
            add1 = result['address'];
            latitude = result['latitude'];
            longitude = result['longitude'];
            locationAddress = result['locationAddress'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Address updated successfully!"),
                ],
              ),
              backgroundColor: KGMS.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error navigating to address edit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Error loading address editor"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadCartItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      cartItemKeys = prefs.getStringList('cartItems') ?? [];

      final productState = ref.watch(productProvider);
      if (productState.data != null) {
        cartProducts.clear();

        for (String cartItemKey in cartItemKeys) {
          List<String> parts = cartItemKey.split('_');
          if (parts.length == 2) {
            String productId = parts[0];
            String distributorId = parts[1];

            try {
              Data matchingProduct = productState.data!.firstWhere(
                (product) =>
                    product.productId == productId &&
                    product.distributorId == distributorId,
              );

              cartProducts.add(matchingProduct);
              productSelections[cartItemKey] =
                  prefs.getBool('selected_$cartItemKey') ?? true;
              productQuantities[cartItemKey] =
                  prefs.getInt('quantity_$cartItemKey') ?? 1;
            } catch (e) {
              debugPrint('Error finding matching product for $cartItemKey: $e');
              // Continue with next item instead of breaking the entire flow
            }
          }
        }
      }

      selectedCartItemKeys = productSelections.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading cart items: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Error loading cart items"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  int get totalSelectedBookingCount {
    int count = 0;
    for (var cartItemKey in productSelections.keys) {
      if (productSelections[cartItemKey] == true) {
        count += productQuantities[cartItemKey] ?? 1;
      }
    }
    return count;
  }

  Future<void> _saveSelection(String cartItemKey, bool isSelected) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('selected_$cartItemKey', isSelected);

      if (mounted) {
        setState(() {
          productSelections[cartItemKey] = isSelected;
          if (isSelected) {
            if (!selectedCartItemKeys.contains(cartItemKey)) {
              selectedCartItemKeys.add(cartItemKey);
            }
          } else {
            selectedCartItemKeys.remove(cartItemKey);
          }
        });
      }
    } catch (e) {
      debugPrint('Error saving selection: $e');
    }
  }

  Future<void> _saveQuantity(String cartItemKey, int quantity) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quantity_$cartItemKey', quantity);

      if (mounted) {
        setState(() {
          productQuantities[cartItemKey] = quantity;
        });
      }
    } catch (e) {
      debugPrint('Error saving quantity: $e');
    }
  }

  Future<void> _proceedToBuy({
    required double totalAmount,
    required double codAdvance,
  }) async {
    try {
      List<Data> selectedProducts = [];

      for (String cartItemKey in selectedCartItemKeys) {
        try {
          Data product = cartProducts.firstWhere(
            (p) => "${p.productId}_${p.distributorId}" == cartItemKey,
          );
          selectedProducts.add(product);
        } catch (e) {
          debugPrint('Error finding selected product for $cartItemKey: $e');
          // Continue with other products
        }
      }

      if (selectedProducts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text("No products selected for booking."),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return;
      }

      int bookedCount = selectedProducts.fold(0, (sum, product) {
        String cartItemKey = "${product.productId}_${product.distributorId}";
        return sum + (productQuantities[cartItemKey] ?? 1);
      });

      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User data is missing.");
      }

      List<Map<String, dynamic>> productIds = selectedProducts.map((product) {
        String cartItemKey = "${product.productId}_${product.distributorId}";
        int quantity = productQuantities[cartItemKey] ?? 1;
        String distributorid = product.distributorId!;
        double userPrice = product.price! + (product.price! * 0.10);

        return {
          "productId": product.productId!,
          "distributorId": distributorid,
          "quantity": quantity,
          "bookingStatus": "pending",
          "userPrice": double.parse(userPrice.toStringAsFixed(2)),
        };
      }).toList();

      double? lat =
          latitude ?? double.tryParse(prefs.getString('latitude') ?? '');
      double? lng =
          longitude ?? double.tryParse(prefs.getString('longitude') ?? '');

      if (lat == null || lng == null) {
        throw Exception("Location data is missing.");
      }

      String location = "$lat, $lng";
      String paymentMethodString = selectedMethod == PaymentMethod.cod
          ? "cod"
          : "onlinepayment";

      await ref
          .read(getproductProvider.notifier)
          .createBooking(
            userId: userid,
            productIds: productIds,
            location: location,
            address: add1,
            bookingOtp: bookingOtp,
            paymentmethod: paymentMethodString,
            codAdvance: paymentMethodString == "cod" ? codAdvance : totalAmount,
            totalPrice: totalAmount,
          );

      cartItemKeys.removeWhere((key) => selectedCartItemKeys.contains(key));
      await prefs.setStringList('cartItems', cartItemKeys);

      selectedCartItemKeys.clear();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text("$bookedCount products booked successfully!"),
            ],
          ),
          backgroundColor: KGMS.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (cartItemKeys.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductsScreen(selectedCategory: 'ALL'),
          ),
        );
      } else {
        setState(() {});
      }
    } catch (error) {
      debugPrint('Error in _proceedToBuy: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Error processing booking. Please try again."),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalBase = 0;
    int totalSelectedBookingCount = 0;

    for (Data product in cartProducts) {
      String cartItemKey = "${product.productId}_${product.distributorId}";
      if (productSelections[cartItemKey] == true) {
        int quantity = productQuantities[cartItemKey] ?? 1;
        totalBase += (product.price ?? 0) * quantity;
        totalSelectedBookingCount++;
      }
    }

    double totalAdded = totalBase * 0.10;
    double userPrice = totalBase + totalAdded;
    double platformFee = userPrice * 0.025;
    double totalAmount = userPrice + platformFee;
    double codAdvance = totalAdded + platformFee;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        title: const Row(
          children: [
            Icon(Icons.shopping_cart_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text("KGMS CART", style: TextStyle(color: Colors.white)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: KGMS.kgmsWhite,
          child: SingleChildScrollView(
            child: cartProducts.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: KGMS.secondaryText,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Your KGMS cart is empty!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: KGMS.primaryText,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Add some KGMS products to get started",
                            style: TextStyle(
                              fontSize: 14,
                              color: KGMS.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Address Section
                      Card(
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        shadowColor: KGMS.primaryBlue.withValues(alpha: 0.2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                KGMS.lightBlue.withValues(alpha: 0.3),
                              ],
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: KGMS.primaryBlue,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.local_shipping_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          "Delivery Details",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: KGMS.primaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            KGMS.primaryGreen,
                                            KGMS.kgmsTeal,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: TextButton.icon(
                                        onPressed: _navigateToAddressEdit,
                                        icon: const Icon(
                                          Icons.edit_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Change",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.home_rounded,
                                      size: 20,
                                      color: KGMS.primaryBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Address:",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: KGMS.primaryText,
                                            ),
                                          ),
                                          Text(
                                            add1 != null && add1!.isNotEmpty
                                                ? add1!
                                                : "No Address",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: KGMS.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 20,
                                      color: KGMS.primaryGreen,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Location:",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: KGMS.primaryText,
                                            ),
                                          ),
                                          Text(
                                            locationAddress,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: KGMS.secondaryText,
                                            ),
                                          ),
                                          if (latitude != null &&
                                              longitude != null)
                                            Text(
                                              "Coordinates: ${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: KGMS.secondaryText
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: KGMS.lightBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: TextButton.icon(
                                        onPressed: () {
                                          _loadAddress();
                                        },
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          size: 16,
                                          color: KGMS.primaryBlue,
                                        ),
                                        label: const Text(
                                          "Reset",
                                          style: TextStyle(
                                            color: KGMS.primaryBlue,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Cart items list
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: SingleChildScrollView(
                          child: Column(
                            children: cartProducts
                                .map((product) => _buildCartItem(product))
                                .toList(),
                          ),
                        ),
                      ),

                      // Price details
                      PriceDetails(
                        totalMRP: userPrice,
                        platformFee: platformFee,
                        totalAmount: totalAmount,
                      ),

                      const SizedBox(height: 20),

                      // Payment Method Selection
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        shadowColor: KGMS.primaryBlue.withValues(alpha: 0.2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                KGMS.lightGreen.withValues(alpha: 0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: KGMS.primaryGreen.withValues(alpha: 0.2),
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
                                        color: KGMS.primaryGreen,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.payment_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Select Payment Method",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: KGMS.primaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color:
                                                selectedMethod ==
                                                    PaymentMethod.cod
                                                ? KGMS.primaryGreen
                                                : KGMS.secondaryText.withValues(
                                                    alpha: 0.3,
                                                  ),
                                            width: 2,
                                          ),
                                          color:
                                              selectedMethod ==
                                                  PaymentMethod.cod
                                              ? KGMS.lightGreen
                                              : Colors.white,
                                        ),
                                        child: RadioListTile<PaymentMethod>(
                                          value: PaymentMethod.cod,
                                          groupValue: selectedMethod,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                selectedMethod = value;
                                              });
                                            }
                                          },
                                          title: const Row(
                                            children: [
                                              // Icon(
                                              //   Icons.money_rounded,
                                              //   color: KGMS.primaryGreen,
                                              //   size: 20,
                                              // ),
                                              // SizedBox(width: 8),
                                              Text("COD"),
                                            ],
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                          activeColor: KGMS.primaryGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color:
                                                selectedMethod ==
                                                    PaymentMethod.online
                                                ? KGMS.primaryBlue
                                                : KGMS.secondaryText.withValues(
                                                    alpha: 0.3,
                                                  ),
                                            width: 2,
                                          ),
                                          color:
                                              selectedMethod ==
                                                  PaymentMethod.online
                                              ? KGMS.lightBlue
                                              : Colors.white,
                                        ),
                                        child: RadioListTile<PaymentMethod>(
                                          value: PaymentMethod.online,
                                          groupValue: selectedMethod,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                selectedMethod = value;
                                              });
                                            }
                                          },
                                          title: const Row(
                                            children: [
                                              // Icon(
                                              //   Icons.credit_card_rounded,
                                              //   color: KGMS.primaryBlue,
                                              //   size: 20,
                                              // ),
                                              // SizedBox(width: 5),
                                              Text("Online"),
                                            ],
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                          activeColor: KGMS.primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors:
                                          selectedMethod == PaymentMethod.online
                                          ? [KGMS.lightBlue, Colors.white]
                                          : [KGMS.lightGreen, Colors.white],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          selectedMethod == PaymentMethod.online
                                          ? KGMS.primaryBlue.withValues(
                                              alpha: 0.3,
                                            )
                                          : KGMS.primaryGreen.withValues(
                                              alpha: 0.3,
                                            ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedMethod ==
                                                  PaymentMethod.online
                                              ? KGMS.primaryBlue
                                              : KGMS.primaryGreen,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          selectedMethod == PaymentMethod.online
                                              ? Icons.credit_card_rounded
                                              : Icons.money_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          selectedMethod == PaymentMethod.online
                                              ? "Full Amount to Pay: ₹${totalAmount.toStringAsFixed(2)}"
                                              : "Advance to Pay: ₹${codAdvance.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: KGMS.primaryText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Selected products count
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [KGMS.kgmsTeal, KGMS.primaryBlue],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: KGMS.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$totalSelectedBookingCount Selected Products for Booking",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Warning if no products selected
                      if (selectedCartItemKeys.isEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_rounded, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Select at least one product to continue",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Continue button
                      Container(
                        margin: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: selectedCartItemKeys.isNotEmpty
                              ? const LinearGradient(
                                  colors: [KGMS.primaryGreen, KGMS.kgmsTeal],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade500,
                                  ],
                                ),
                          boxShadow: selectedCartItemKeys.isNotEmpty
                              ? [
                                  BoxShadow(
                                    color: KGMS.primaryGreen.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: selectedCartItemKeys.isNotEmpty
                              ? () {
                                  double payAmount =
                                      selectedMethod == PaymentMethod.online
                                      ? totalAmount
                                      : codAdvance;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RazorpayPaymentPage(
                                        amount: payAmount,
                                        onSuccess: () => _proceedToBuy(
                                          totalAmount: totalAmount,
                                          codAdvance: codAdvance,
                                        ),
                                        email: '',
                                        contact: '',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Continue to Payment",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(Data product) {
    String cartItemKey = "${product.productId}_${product.distributorId}";
    int quantity = productQuantities[cartItemKey] ?? 1;
    bool isSelected = productSelections[cartItemKey] ?? true;
    int maxLimit = product.quantity ?? 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      shadowColor: KGMS.primaryBlue.withValues(alpha: 0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, KGMS.lightBlue.withValues(alpha: 0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isSelected
                ? KGMS.primaryBlue.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? KGMS.primaryBlue : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        if (value != null) {
                          _saveSelection(cartItemKey, value);
                        }
                      },
                      activeColor: KGMS.primaryBlue,
                      side: BorderSide.none,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: KGMS.primaryBlue.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      image: product.productImages != null
                          ? DecorationImage(
                              image: NetworkImage(
                                "${product.productImages?.first}",
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: KGMS.lightBlue,
                    ),
                    child: product.productImages == null
                        ? const Icon(
                            Icons.medical_services_rounded,
                            color: KGMS.primaryBlue,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: KGMS.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.productDescription ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: KGMS.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_rounded,
                              size: 14,
                              color: KGMS.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Available: ${product.quantity}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: KGMS.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              "Qty:",
                              style: TextStyle(
                                fontSize: 14,
                                color: KGMS.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: KGMS.primaryBlue.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline_rounded,
                                      color: quantity > 1
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: quantity > 1
                                        ? () {
                                            _saveQuantity(
                                              cartItemKey,
                                              quantity - 1,
                                            );
                                          }
                                        : null,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      "$quantity",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: KGMS.primaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: quantity < maxLimit
                                          ? KGMS.primaryGreen
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: quantity < maxLimit
                                        ? () {
                                            _saveQuantity(
                                              cartItemKey,
                                              quantity + 1,
                                            );
                                          }
                                        : () {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.warning_rounded,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "Only $maxLimit available for this product.",
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: KGMS.primaryGreen,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "₹${(product.price! * 1.10).toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: KGMS.secondaryText),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await _removeFromCart(cartItemKey);
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    label: const Text(
                      "Remove",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search_rounded,
                      color: KGMS.primaryBlue,
                      size: 18,
                    ),
                    label: const Text(
                      "Find Similar",
                      style: TextStyle(
                        color: KGMS.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: KGMS.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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

  Future<void> _removeFromCart(String cartItemKey) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      cartItemKeys.remove(cartItemKey);
      await prefs.setStringList('cartItems', cartItemKeys);

      cartProducts.removeWhere(
        (product) =>
            "${product.productId}_${product.distributorId}" == cartItemKey,
      );
      productSelections.remove(cartItemKey);
      productQuantities.remove(cartItemKey);
      selectedCartItemKeys.remove(cartItemKey);

      await prefs.remove('selected_$cartItemKey');
      await prefs.remove('quantity_$cartItemKey');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Item removed from cart",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        setState(() {});
      }
    } catch (e) {
      debugPrint('Error removing item from cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Error removing item from cart"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

class PriceDetails extends StatelessWidget {
  final double totalMRP;
  final double totalAmount;
  final double platformFee;

  const PriceDetails({
    super.key,
    required this.totalMRP,
    required this.totalAmount,
    required this.platformFee,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      shadowColor: KGMS.primaryBlue.withValues(alpha: 0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, KGMS.lightGreen.withValues(alpha: 0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: KGMS.primaryGreen.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KGMS.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Price Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KGMS.primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRow("Total MRP:", "₹${totalMRP.toStringAsFixed(2)}"),
              _buildRow(
                "Platform Fee (2.5%):",
                "+₹${platformFee.toStringAsFixed(2)}",
              ),
              const Divider(thickness: 2, color: KGMS.primaryGreen),
              _buildRow(
                "Total Amount:",
                "₹${totalAmount.toStringAsFixed(2)}",
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
              color: KGMS.primaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
              color: isBold ? KGMS.primaryGreen : KGMS.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
