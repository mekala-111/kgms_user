import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors/colors.dart';

class AddressEditScreen extends StatefulWidget {
  final String? currentAddress;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentLocationAddress;

  const AddressEditScreen({
    super.key,
    this.currentAddress,
    this.currentLatitude,
    this.currentLongitude,
    this.currentLocationAddress,
  });

  @override
  State<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  late TextEditingController addressController;
  late TextEditingController locationSearchController;

  final FocusNode addressFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();

  String? updatedAddress;
  double? updatedLatitude;
  double? updatedLongitude;
  String locationAddress = "";

  bool hasAddressChanged = false;
  bool hasLocationChanged = false;
  bool isUpdatingLocation = false;
  bool isGettingCurrentLocation = false;

  @override
  void initState() {
    super.initState();

    addressController =
        TextEditingController(text: widget.currentAddress ?? "");
    locationSearchController = TextEditingController();

    updatedAddress = widget.currentAddress;
    updatedLatitude = widget.currentLatitude;
    updatedLongitude = widget.currentLongitude;
    locationAddress = widget.currentLocationAddress ?? "Location not selected";

    addressController.addListener(() {
      if (!isUpdatingLocation &&
          addressController.text != widget.currentAddress) {
        setState(() {
          hasAddressChanged = true;
          updatedAddress = addressController.text;
        });
      }
    });

    locationSearchController.addListener(() {
      if (locationSearchController.text.isEmpty) {
        setState(() {
          updatedLatitude = widget.currentLatitude;
          updatedLongitude = widget.currentLongitude;
          locationAddress =
              widget.currentLocationAddress ?? "Location not selected";
          hasLocationChanged = false;
        });
      }
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    locationSearchController.dispose();
    addressFocusNode.dispose();
    locationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        setState(() {
          locationAddress =
              "${place.street}, ${place.locality}, ${place.country}";
          hasLocationChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          locationAddress = "Could not fetch location";
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (hasAddressChanged && updatedAddress != null) {
        await prefs.setString('add1', updatedAddress!);
      }

      if (hasLocationChanged &&
          updatedLatitude != null &&
          updatedLongitude != null) {
        await prefs.setString('latitude', updatedLatitude.toString());
        await prefs.setString('longitude', updatedLongitude.toString());
        await prefs.setString('locationAddress', locationAddress);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text("Address and location updated successfully!"),
            ],
          ),
          backgroundColor: KGMS.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context, {
        'address': updatedAddress,
        'latitude': updatedLatitude,
        'longitude': updatedLongitude,
        'locationAddress': locationAddress,
        'hasChanges': hasAddressChanged || hasLocationChanged,
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text("Error saving changes: $e"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _resetLocation() {
    setState(() {
      updatedLatitude = widget.currentLatitude;
      updatedLongitude = widget.currentLongitude;
      locationAddress =
          widget.currentLocationAddress ?? "Location not selected";
      locationSearchController.clear();
      hasLocationChanged = false;
    });
  }

  void _resetAddress() {
    setState(() {
      isUpdatingLocation = true;
      addressController.text = widget.currentAddress ?? "";
      updatedAddress = widget.currentAddress;
      hasAddressChanged = false;
      isUpdatingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasAnyChanges = hasAddressChanged || hasLocationChanged;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (hasAnyChanges) {
              _showUnsavedChangesDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_location_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "Edit KGMS Address",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: PopScope(
        canPop: !hasAnyChanges,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && hasAnyChanges) {
            _showUnsavedChangesDialog();
          }
        },
        child: Container(
          color: KGMS.kgmsWhite,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address Section
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  shadowColor: KGMS.primaryBlue.withValues(alpha: 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          KGMS.lightBlue.withValues(alpha: 0.3)
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: KGMS.primaryBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.home_rounded,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Delivery Address",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: KGMS.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                              if (hasAddressChanged)
                                Container(
                                  decoration: BoxDecoration(
                                    color: KGMS.lightBlue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.refresh_rounded,
                                        color: KGMS.primaryBlue),
                                    onPressed: _resetAddress,
                                    tooltip: "Reset Address",
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      KGMS.primaryBlue.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: addressController,
                              focusNode: addressFocusNode,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "KGMS Delivery Address",
                                hintText: "Enter your delivery address",
                                labelStyle:
                                    const TextStyle(color: KGMS.primaryBlue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: KGMS.primaryBlue
                                          .withValues(alpha: 0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: KGMS.primaryBlue
                                          .withValues(alpha: 0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: KGMS.primaryBlue, width: 2),
                                ),
                                prefixIcon: const Icon(Icons.home_rounded,
                                    color: KGMS.primaryBlue),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          if (hasAddressChanged)
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_rounded,
                                      color: Colors.orange, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    "Address has been modified",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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

                const SizedBox(height: 20),

                // Location Section
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  shadowColor: KGMS.primaryGreen.withValues(alpha: 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          KGMS.lightGreen.withValues(alpha: 0.3)
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: KGMS.primaryGreen,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.location_on_rounded,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: KGMS.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                              if (hasLocationChanged)
                                Container(
                                  decoration: BoxDecoration(
                                    color: KGMS.lightGreen,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.refresh_rounded,
                                        color: KGMS.primaryGreen),
                                    onPressed: _resetLocation,
                                    tooltip: "Reset Location",
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Google Places Search
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      KGMS.primaryGreen.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: GooglePlaceAutoCompleteTextField(
                              textEditingController: locationSearchController,
                              focusNode: locationFocusNode,
                              googleAPIKey:
                                  "AIzaSyDcEBHY-4sTUz254VZ9OD3Xr-7462LvBts",
                              inputDecoration: InputDecoration(
                                hintText: "Search for KGMS facility location",
                                hintStyle:
                                    const TextStyle(color: KGMS.secondaryText),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: KGMS.primaryGreen
                                          .withValues(alpha: 0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: KGMS.primaryGreen
                                          .withValues(alpha: 0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: KGMS.primaryGreen, width: 2),
                                ),
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: KGMS.primaryGreen),
                                suffixIcon: locationSearchController
                                        .text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded,
                                            color: KGMS.secondaryText),
                                        onPressed: () {
                                          locationSearchController.clear();
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              debounceTime: 800,
                              isLatLngRequired: true,
                              getPlaceDetailWithLatLng: (prediction) {
                                isUpdatingLocation = true;

                                double lat = double.parse(prediction.lat!);
                                double lng = double.parse(prediction.lng!);

                                setState(() {
                                  updatedLatitude = lat;
                                  updatedLongitude = lng;
                                });

                                _getAddressFromCoordinates(lat, lng).then((_) {
                                  if (mounted) {
                                    isUpdatingLocation = false;
                                  }
                                });
                              },
                              itemClick: (prediction) {
                                locationSearchController.text =
                                    prediction.description!;
                                locationSearchController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: prediction.description!.length),
                                );

                                // Use FocusNode directly - no BuildContext needed!
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  if (mounted) {
                                    locationFocusNode
                                        .requestFocus(); // ✅ No context required
                                  }
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Current Location Display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  KGMS.lightGreen.withValues(alpha: 0.5),
                                  Colors.white
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      KGMS.primaryGreen.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.place_rounded,
                                        color: KGMS.primaryGreen, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Selected Location:",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: KGMS.primaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  locationAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: KGMS.primaryText,
                                  ),
                                ),
                                if (updatedLatitude != null &&
                                    updatedLongitude != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: KGMS.primaryGreen
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Coordinates: ${updatedLatitude!.toStringAsFixed(6)}, ${updatedLongitude!.toStringAsFixed(6)}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: KGMS.primaryGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          if (hasLocationChanged)
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_location_rounded,
                                      color: Colors.orange, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    "Location has been modified",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: hasAnyChanges
                              ? const LinearGradient(
                                  colors: [KGMS.primaryGreen, KGMS.kgmsTeal],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade500
                                  ],
                                ),
                          boxShadow: hasAnyChanges
                              ? [
                                  BoxShadow(
                                    color: KGMS.primaryGreen
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: hasAnyChanges ? _saveChanges : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasAnyChanges
                                    ? Icons.save_rounded
                                    : Icons.save_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasAnyChanges
                                    ? "Save Changes"
                                    : "No Changes",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (hasAnyChanges) {
                            _showUnsavedChangesDialog();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                              color: KGMS.primaryBlue, width: 2),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_rounded,
                                color: KGMS.primaryBlue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: KGMS.primaryBlue,
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
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            const Text(
              "Unsaved Changes",
              style: TextStyle(color: KGMS.primaryText),
            ),
          ],
        ),
        content: const Text(
          "You have unsaved changes. What would you like to do?",
          style: TextStyle(color: KGMS.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "Discard Changes",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KGMS.primaryGreen, KGMS.kgmsTeal],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveChanges();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              child: const Text(
                "Save & Exit",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Continue Editing",
              style: TextStyle(
                  color: KGMS.primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
