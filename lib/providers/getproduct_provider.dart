import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/auth.dart' hide Data;
import 'package:kgms_user/model/get_productbooking.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:kgms_user/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetproductProvider extends StateNotifier<GetproductModel> {
  final Ref ref;
  GetproductProvider(this.ref) : super(GetproductModel.initial());

  Future<void> createBooking({
    required String? userId,
    required List<Map<String, dynamic>> productIds,
    required String location,
    required String? address,
    required String? bookingOtp,
    required String? paymentmethod,
    required double? codAdvance,
    required double? totalPrice,
  }) async {
    try {
      // Retrieve token from SharedPreferences
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

      // Initialize retry logic
      final client = RetryClient(
        http.Client(),
        retries: 3,
        when: (response) =>
            response.statusCode == 400 || response.statusCode == 401,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 400 || res?.statusCode == 401)) {
            // Token refresh logic
            String? newAccessToken = await ref
                .read(userProvider.notifier)
                .restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "userId": userId ?? '',
        "location": location,
        "address": address ?? '',
        "status": "pending",
        "products": productIds,
        "Otp": bookingOtp,
        "paidPrice": codAdvance,
        "type": paymentmethod,
        "totalPrice": totalPrice,
      };

      // Send POST request with JSON body
      final response = await client.post(
        Uri.parse(Bbapi.createbooking),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Send Request
      // final streamedResponse = await client.send(request);
      // final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Unexpected error occurred.';
        throw Exception("Error creating booking: $errorMessage");
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getuserproduct() async {
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
        Uri.parse(Bbapi.getproductbooking),
        headers: {"Authorization": "Bearer $token"},
      );

      final responseBody = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        final productData = GetproductModel.fromJson(res);

        // Ensure data is not null before filtering
        final List<Data> userProducts =
            productData.data
                ?.where((booking) => booking.userId?.sId == loggedInUserId)
                .toList() ??
            [];

        state = GetproductModel(
          statusCode: productData.statusCode,
          success: productData.success,
          messages: productData.messages,
          data: userProducts, // Update state with filtered data
        );
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching booking products: $errorMessage");
      }
    } finally {
      loadingState.state = false;
    }
  }

  Future<bool> cancelBooking(
    String? bookingId,
    String productId,
    String distributorId,
  ) async {
    final String apiUrl = "${Bbapi.updateproductbooking}/$bookingId";
    final loadingState = ref.read(loadingProvider.notifier);
    final loginprovider = ref.read(userProvider);
    final token = loginprovider.data?[0].accessToken;

    try {
      loadingState.state = true;

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

      final request = http.Request("PATCH", Uri.parse(apiUrl));
      request.headers.addAll({
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      request.body = jsonEncode({
        "products": [
          {
            "distributorId": distributorId,
            "productId": productId,
            "bookingStatus": "cancelled", // You can also pass a variable here
          },
        ],
      });

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      loadingState.state = false;
    }
  }
}

final getproductProvider =
    StateNotifierProvider<GetproductProvider, GetproductModel>((ref) {
      return GetproductProvider(ref);
    });
