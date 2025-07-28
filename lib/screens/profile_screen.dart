import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'dart:async';

import '../colors/colors.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends ConsumerState<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool isEditing = false;
  bool isEditingLocation = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  File? _selectedImage;
  String? _profileImageUrl;
  final double maxImageSize = 5 * 1024 * 1024;

  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  LatLng _currentPosition = const LatLng(17.4065, 78.4772);
  final Set<Marker> _markers = {};
  String _currentAddress = "No location selected";
  double? lat;
  double? lng;
  bool _isMapReady = false;
  bool _isLoadingLocation = false;

  Timer? _searchDebounce;
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeMap();
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _initializeMap() {
    if (mounted) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    searchController.dispose();

    if (_mapController != null) {
      _mapController!.dispose();
    }

    super.dispose();
  }

  void _loadUserData() {
    final userModel = ref.watch(userProvider);
    if (userModel.data != null && userModel.data!.isNotEmpty) {
      final user = userModel.data![0].user;
      if (mounted) {
        setState(() {
          nameController.text = user?.name ?? "";
          emailController.text = user?.email ?? "";
          phoneController.text = user?.mobile ?? "";
          addressController.text = user?.address ?? "";
          _profileImageUrl = user?.profileImage?.isNotEmpty == true
              ? user?.profileImage![0]
              : null;

          if (user?.location?.latitude != null &&
              user?.location?.longitude != null) {
            lat =
                double.tryParse(user?.location?.latitude.toString() ?? '') ??
                0.0;
            lng =
                double.tryParse(user?.location?.longitude.toString() ?? '') ??
                0.0;
            _currentPosition = LatLng(lat!, lng!);
            _currentAddress = user!.address ?? "Saved location";
            _updateMapMarker();
          }
        });
      }
    }
  }

  void _updateMapMarker() async {
    if (lat != null && lng != null && mounted) {
      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId("selectedLocation"),
              position: LatLng(lat!, lng!),
              infoWindow: InfoWindow(
                title: "Selected Location",
                snippet: _currentAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );
        });
      }

      if (_isMapReady && _mapControllerCompleter.isCompleted && mounted) {
        try {
          final GoogleMapController controller =
              await _mapControllerCompleter.future;
          if (mounted) {
            await controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(lat!, lng!), zoom: 16),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error updating map camera: $e');
          if (mounted) {
            _showErrorSnackBar("Failed to update map view");
          }
        }
      }
    }
  }

  String _formatAddress(Placemark placemark) {
    List<String?> addressComponents = [
      placemark.name,
      placemark.street,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ].where((component) => component != null && component.isNotEmpty).toList();

    return addressComponents.join(', ');
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
      });
    }

    final loc.Location location = loc.Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (mounted) {
            _showErrorSnackBar("Location service is disabled");
            setState(() {
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          if (mounted) {
            _showErrorSnackBar("Location permission denied");
            setState(() {
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      await location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 10,
      );

      loc.LocationData locationData = await location.getLocation().timeout(
        const Duration(seconds: 15),
      );

      if (locationData.latitude == null || locationData.longitude == null) {
        if (mounted) {
          _showErrorSnackBar("Unable to get current location");
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      lat = locationData.latitude;
      lng = locationData.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat!,
        lng!,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty && mounted) {
        String address = _formatAddress(placemarks.first);

        if (mounted) {
          setState(() {
            _currentPosition = LatLng(lat!, lng!);
            _currentAddress = address;
            searchController.text = "";
            if (isEditingLocation) {
              addressController.text = address;
            }
          });
        }

        _updateMapMarker();

        if (mounted) {
          _showSuccessSnackBar("Current location updated");
        }
      }
    } on TimeoutException {
      if (mounted) {
        _showErrorSnackBar("Location timeout. Please try again.");
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        _showErrorSnackBar(
          "Error getting current location. Please check your location settings.",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _onMapTap(LatLng position) async {
    if (!isEditingLocation || !mounted) return;

    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
      });
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      String address = placemarks.isNotEmpty
          ? _formatAddress(placemarks.first)
          : "Selected location";

      if (mounted) {
        setState(() {
          lat = position.latitude;
          lng = position.longitude;
          _currentPosition = position;
          _currentAddress = address;
          searchController.text = "";
          if (isEditingLocation) {
            addressController.text = address;
          }
        });

        _updateMapMarker();
      }
    } catch (e) {
      debugPrint('Error getting address for selected location: $e');

      if (mounted) {
        setState(() {
          lat = position.latitude;
          lng = position.longitude;
          _currentPosition = position;
          _currentAddress = "Selected location";
          if (isEditingLocation) {
            addressController.text = "Selected location";
          }
        });
        _updateMapMarker();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: KGMS.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: KGMS.successGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (image != null && mounted) {
        final File imageFile = File(image.path);
        final int imageSize = await imageFile.length();

        if (imageSize <= maxImageSize) {
          if (mounted) {
            setState(() {
              _selectedImage = imageFile;
            });
          }
        } else {
          if (mounted) {
            _showSizeError();
          }
        }
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
      if (mounted) {
        _showErrorSnackBar("Error selecting image. Please try again.");
      }
    }
  }

  void _showSizeError() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Image Too Large",
          style: TextStyle(color: KGMS.primaryText),
        ),
        content: const Text(
          "The selected image exceeds the size limit of 5 MB. Please choose a smaller image.",
          style: TextStyle(color: KGMS.secondaryText),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: KGMS.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveProfile() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: KGMS.kgmsTeal),
            SizedBox(height: 16),
            Text(
              "Updating Profile...",
              style: TextStyle(
                color: KGMS.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final results = await ref
          .read(userProvider.notifier)
          .updateProfile(
            nameController.text,
            emailController.text,
            phoneController.text,
            addressController.text,
            lat,
            lng,
            _selectedImage,
            ref,
          );

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      // Close the loading dialog with fresh context
      Navigator.of(context).pop();

      if (results == true) {
        _showSuccessSnackBar("Profile Updated Successfully!");
      } else {
        _showErrorSnackBar("Failed to update profile");
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');

      if (!mounted) return;

      // Close the loading dialog with fresh context
      Navigator.of(context).pop();
      _showErrorSnackBar("Error updating profile: Failed to save changes");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: KGMS.kgmsTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [KGMS.lightBlue.withValues(alpha: 0.3), KGMS.kgmsWhite],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image and Name Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: KGMS.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isEditing
                          ? () => _showImageSourceActionSheet()
                          : null,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: KGMS.kgmsTeal.withValues(alpha: 0.3),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: KGMS.lightBlue.withValues(
                                alpha: 0.5,
                              ),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : _profileImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      _profileImageUrl!,
                                    )
                                  : null,
                              child:
                                  _selectedImage == null &&
                                      _profileImageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 55,
                                      color: KGMS.kgmsTeal,
                                    )
                                  : null,
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: KGMS.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      nameController.text.isNotEmpty
                          ? nameController.text
                          : "User Name",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: KGMS.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: KGMS.lightBlue.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isEditing ? "Editing Profile" : "View Profile",
                        style: const TextStyle(
                          fontSize: 12,
                          color: KGMS.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Profile Fields Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: KGMS.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: KGMS.kgmsTeal,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: KGMS.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      "Name",
                      nameController,
                      isEditing,
                      Icons.person,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildProfileField(
                      "Email",
                      emailController,
                      isEditing,
                      Icons.email,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildProfileField(
                      "Phone",
                      phoneController,
                      isEditing,
                      Icons.phone,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildProfileField(
                      "Address",
                      addressController,
                      isEditing && isEditingLocation,
                      Icons.location_on,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Location Section Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: KGMS.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: KGMS.kgmsTeal,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Location",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: KGMS.primaryText,
                              ),
                            ),
                          ],
                        ),
                        if (isEditing)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isEditingLocation = !isEditingLocation;
                              });
                            },
                            icon: Icon(
                              isEditingLocation
                                  ? Icons.check
                                  : Icons.edit_location,
                              size: 16,
                            ),
                            label: Text(isEditingLocation ? "Done" : "Edit"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEditingLocation
                                  ? KGMS.successGreen
                                  : KGMS.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Current Address Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KGMS.lightBlue.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: KGMS.kgmsTeal.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: KGMS.kgmsTeal,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _currentAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                color: KGMS.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isEditingLocation) ...[
                      const SizedBox(height: 16),

                      // Google Places Search
                      GooglePlaceAutoCompleteTextField(
                        textEditingController: searchController,
                        googleAPIKey: "AIzaSyDcEBHY-4sTUz254VZ9OD3Xr-7462LvBts",
                        inputDecoration: InputDecoration(
                          hintText: "Search location...",
                          hintStyle: const TextStyle(color: KGMS.lightText),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: KGMS.kgmsTeal,
                          ),
                          filled: true,
                          fillColor: KGMS.surfaceGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: KGMS.lightBlue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: KGMS.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: KGMS.kgmsTeal,
                              width: 2,
                            ),
                          ),
                        ),
                        debounceTime: 800,
                        isLatLngRequired: true,
                        countries: const ["in"],
                        getPlaceDetailWithLatLng: (prediction) {
                          if (prediction.lat != null &&
                              prediction.lng != null &&
                              mounted) {
                            double newLat = double.parse(prediction.lat!);
                            double newLng = double.parse(prediction.lng!);
                            String newAddress = prediction.description ?? "";

                            setState(() {
                              lat = newLat;
                              lng = newLng;
                              _currentPosition = LatLng(newLat, newLng);
                              _currentAddress = newAddress;
                              addressController.text = newAddress;
                            });

                            _updateMapMarker();
                          }
                        },
                        itemClick: (prediction) {
                          if (mounted) {
                            FocusScope.of(context).unfocus();
                            searchController.text = prediction.description!;
                            searchController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: prediction.description!.length,
                                  ),
                                );
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Location Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingLocation
                              ? null
                              : _getCurrentLocation,
                          icon: _isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(
                            _isLoadingLocation
                                ? "Getting Location..."
                                : "Use Current Location",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KGMS.accentTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        "Tap on the map to select a location",
                        style: TextStyle(
                          fontSize: 12,
                          color: KGMS.lightText,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Google Maps Widget
              Container(
                height: isEditingLocation ? 400 : 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition,
                      zoom: 14,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: !isEditingLocation,
                    onTap: isEditingLocation ? _onMapTap : null,
                    zoomControlsEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                    buildingsEnabled: false,
                    trafficEnabled: false,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: false,
                    zoomGesturesEnabled: true,
                    liteModeEnabled: false,
                    padding: const EdgeInsets.all(8.0),
                    cameraTargetBounds: CameraTargetBounds.unbounded,
                    minMaxZoomPreference: const MinMaxZoomPreference(3.0, 20.0),
                    style: '''
                      [
                        {
                          "featureType": "poi.business",
                          "elementType": "labels",
                          "stylers": [{"visibility": "off"}]
                        },
                        {
                          "featureType": "transit",
                          "elementType": "labels",
                          "stylers": [{"visibility": "off"}]
                        }
                      ]
                    ''',
                    onMapCreated: (GoogleMapController controller) async {
                      if (!_mapControllerCompleter.isCompleted) {
                        _mapControllerCompleter.complete(controller);
                        _mapController = controller;
                      }

                      if (mounted) {
                        setState(() {
                          _isMapReady = true;
                        });

                        if (lat != null && lng != null && mounted) {
                          try {
                            await controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(lat!, lng!),
                                  zoom: 16,
                                ),
                              ),
                            );
                          } catch (e) {
                            debugPrint('Error initializing map camera: $e');
                          }
                        }
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Save/Edit Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isEditing) {
                        await _handleSaveProfile();
                      }

                      if (mounted) {
                        setState(() {
                          isEditing = !isEditing;
                          if (!isEditing) {
                            isEditingLocation = false;
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing
                          ? KGMS.successGreen
                          : KGMS.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                        horizontal: screenWidth * 0.1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isEditing ? Icons.save : Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Save Profile' : 'Edit Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    bool isEnabled,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: KGMS.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEnabled,
          keyboardType: label == "Email"
              ? TextInputType.emailAddress
              : label == "Phone"
              ? TextInputType.phone
              : TextInputType.text,
          style: TextStyle(
            color: isEnabled ? KGMS.primaryText : KGMS.secondaryText,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: isEnabled ? KGMS.kgmsTeal : KGMS.lightText,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: KGMS.lightBlue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: KGMS.lightBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: KGMS.kgmsTeal, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: KGMS.lightText.withValues(alpha: 0.3),
              ),
            ),
            filled: true,
            fillColor: isEnabled ? KGMS.cardBackground : KGMS.surfaceGrey,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceActionSheet() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: KGMS.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: KGMS.lightText,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Select Profile Picture",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KGMS.primaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: KGMS.lightBlue.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: KGMS.primaryBlue,
                      ),
                    ),
                    title: const Text(
                      "Take a photo",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: KGMS.primaryText,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: KGMS.lightGreen.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: KGMS.primaryGreen,
                      ),
                    ),
                    title: const Text(
                      "Choose from gallery",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: KGMS.primaryText,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
