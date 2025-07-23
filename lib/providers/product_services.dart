import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/getservices.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:kgms_user/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Productserviceprovider extends StateNotifier<ProductservicesModel> {
  final Ref ref; // To access other providers
  Productserviceprovider(this.ref) : super((ProductservicesModel.initial()));

  Future<void> getproductSevices() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
      final pref = await SharedPreferences.getInstance();
      String? userDataString = pref.getString('userData');
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
      // Initialize RetryClient for handling retries
      final client = RetryClient(
        http.Client(),
        retries: 3, // Retry up to 3 times
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
        Uri.parse(Bbapi.getProductservices),
        headers: {"Authorization": "Bearer $token"},
      );
      final responseBody = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final serviceData = ProductservicesModel.fromJson(res);
        state = serviceData;
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching productservices: $errorMessage");
      }
    } catch (e) {
      //print("Failed to fetch productservices: $e");
    } finally {
      loadingState.state = false;
    }
  }
}

// Define productProvider with ref
final productserviceprovider =
    StateNotifierProvider<Productserviceprovider, ProductservicesModel>((ref) {
      return Productserviceprovider(ref);
    });
