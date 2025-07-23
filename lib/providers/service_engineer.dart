import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/service_engineer_model.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:kgms_user/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServiceEngineerNotifier extends StateNotifier<ServiceEngineerModel> {
  final Ref ref;
  ServiceEngineerNotifier(this.ref) : super(ServiceEngineerModel.initial());

  Future<void> getServiceengineers() async {
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

      final response = await http.get(
        Uri.parse(Bbapi.getServiceengineers),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 401) {
        String? newAccessToken = await ref
            .read(userProvider.notifier)
            .restoreAccessToken();

        if (newAccessToken.isNotEmpty) {
          userData['accessToken'] = newAccessToken;
          pref.setString('userData', jsonEncode(userData));

          final retryResponse = await http.get(
            Uri.parse(Bbapi.getServiceengineers),
            headers: {"Authorization": "Bearer $newAccessToken"},
          );

          if (retryResponse.statusCode == 200 ||
              retryResponse.statusCode == 201) {
            final res = json.decode(retryResponse.body);
            final serviceengineerData = ServiceEngineerModel.fromJson(res);
            state = serviceengineerData;
            return;
          }
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(response.body);
        final serviceengineerData = ServiceEngineerModel.fromJson(res);
        state = serviceengineerData;
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching serviceengineers: $errorMessage");
      }
    } catch (e) {
      // Proper exception handling - one of these approaches:
    } finally {
      // Always turn off loading state
      loadingState.state = false;
    }
  }
}

final serviceEngineer =
    StateNotifierProvider<ServiceEngineerNotifier, ServiceEngineerModel>((ref) {
      return ServiceEngineerNotifier(ref);
    });
