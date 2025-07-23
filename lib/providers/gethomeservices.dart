import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/service.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:kgms_user/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Serviceprovider extends StateNotifier<ServiceModel> {
  final Ref ref; // To access other providers
  Serviceprovider(this.ref) : super((ServiceModel.initial()));

  Future<void> getSevices() async {
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
        Uri.parse(Bbapi.getservices),
        headers: {"Authorization": "Bearer $token"},
      );
      final responseBody = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final serviceData = ServiceModel.fromJson(res);
        state = serviceData;
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching services: $errorMessage");
      }
    } catch (e) {
      // Log the error for debugging purposes
      developer.log(
        'Error in getSevices: $e',
        name: 'Serviceprovider',
        error: e,
      );

      // Optionally, you can also update the state to reflect the error
      // state = ServiceModel.withError(e.toString());

      // Re-throw the error if you want calling code to handle it
      // rethrow;
    } finally {
      // Ensure loading state is always set to false
      loadingState.state = false;
    }
  }
}

// Define productProvider with ref
final serviceProvider = StateNotifierProvider<Serviceprovider, ServiceModel>((
  ref,
) {
  return Serviceprovider(ref);
});
