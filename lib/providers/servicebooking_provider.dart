import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/auth.dart' hide Data;
import 'package:kgms_user/model/servicebooking.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:kgms_user/utils/gomed_api.dart';
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GetserviceProvider extends StateNotifier<ServicebookingModel> {
  final Ref ref;
  GetserviceProvider(this.ref) : super(ServicebookingModel.initial());

  Future<void> addServices({
    required String? userId,
    required List<String> serviceId,
    required String productId,
    required String location,
    required String? address,
    required String date,
    required String time,
    required String startOtp,
    required String endOtp,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User token is missing. Please log in again.");
      }

      final Map<String, dynamic> userData = jsonDecode(userDataString);
      String? token = userData['accessToken'];

      if (token == null || token.isEmpty) {
        token =
            userData['data'] != null &&
                (userData['data'] as List).isNotEmpty &&
                userData['data'][0]['access_token'] != null
            ? userData['data'][0]['access_token']
            : null;
      }

      if (token == null || token.isEmpty) {
        throw Exception("User token is invalid. Please log in again.");
      }

      final client = RetryClient(
        http.Client(),
        retries: 3,
        when: (response) =>
            response.statusCode == 400 || response.statusCode == 401,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 400 || res?.statusCode == 401)) {
            String? newAccessToken = await ref
                .read(userProvider.notifier)
                .restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      final Map<String, dynamic> requestBody = {
        "userId": userId ?? '',
        "serviceIds": serviceId,
        "productId": productId,
        "location": location,
        "address": address ?? '',
        "date": date,
        "time": time,
        "startOtp": startOtp,
        "endOtp": endOtp,
        "status": "pending",
      };

      final response = await client.post(
        Uri.parse(Bbapi.servicebooking),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        jsonDecode(response.body);
        //state = AddservicesModel.fromJson(responseBody);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Unexpected error occurred.';
        throw Exception("Error creating service booking: $errorMessage");
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getUserBookedServices() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;

      // Retrieve user data from SharedPreferences
      final pref = await SharedPreferences.getInstance();
      String? userDataString = pref.getString('userData');

      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User data is missing. Please log in again.");
      }

      // Decode the user data JSON
      final Map<String, dynamic> userDataJson = jsonDecode(userDataString);
      // Debugging

      // Convert JSON to UserModel
      UserModel userModel = UserModel.fromJson(userDataJson);

      // Extract the first available user ID
      String? loggedInUserId;
      if (userModel.data != null && userModel.data!.isNotEmpty) {
        loggedInUserId = userModel.data!.first.user?.sId;
      }

      if (loggedInUserId == null || loggedInUserId.isEmpty) {
        throw Exception("User ID not found. Debug: ${userModel.toJson()}");
      }

      String? token = userModel.data?.first.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token missing.");
      }

      final client = RetryClient(
        http.Client(),
        retries: 3,
        when: (response) =>
            response.statusCode == 401 || response.statusCode == 400,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 401 || res?.statusCode == 400)) {
            String? newAccessToken = await ref
                .read(userProvider.notifier)
                .restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      final response = await client.get(
        Uri.parse(Bbapi.getBookedServices), // Updated API URL
        headers: {"Authorization": "Bearer $token"},
      );

      final responseBody = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        final bookingData = ServicebookingModel.fromJson(res);

        // Ensure `data` is not null before filtering
        final List<Data> userBookedServices =
            bookingData.data
                ?.where((booking) => booking.userId?.sId == loggedInUserId)
                .toList() ??
            [];

        state = ServicebookingModel(
          statusCode: bookingData.statusCode,
          success: bookingData.success,
          messages: bookingData.messages,
          data: userBookedServices, // Update state with filtered data
        );
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching booked services: $errorMessage");
      }
    } finally {
      loadingState.state = false;
    }
  }

  Future<bool> cancelUserService(String? bookingId) async {
    final String apiUrl =
        "${Bbapi.cancelbookedservices}/$bookingId"; // Replace with actual API endpoint
    final loadingState = ref.read(loadingProvider.notifier);
    final loginprovider = ref.read(userProvider);
    final token = loginprovider.data?[0].accessToken;

    try {
      loadingState.state = true; // Show loading state
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token missing.");
      }
      final client = RetryClient(
        http.Client(),
        retries: 3,
        when: (response) =>
            response.statusCode == 401 || response.statusCode == 400,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 401 || res?.statusCode == 400)) {
            String? newAccessToken = await ref
                .read(userProvider.notifier)
                .restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      final response = await client.delete(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Include token
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      loadingState.state = false; // Hide loading state
    }
  }
}

final getserviceProvider =
    StateNotifierProvider<GetserviceProvider, ServicebookingModel>((ref) {
      return GetserviceProvider(ref);
    });
