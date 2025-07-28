import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/service.dart';
import 'package:kgms_user/providers/auth_state.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:kgms_user/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Serviceprovider extends StateNotifier<ServiceModel> {
  final Ref ref;
  bool _hasFetched = false;

  Serviceprovider(this.ref) : super(ServiceModel.initial());

  Future<void> getSevices() async {
    if (_hasFetched && state.data != null && state.data!.isNotEmpty) return;

    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;

      final pref = await SharedPreferences.getInstance();
      String? userDataString = pref.getString('userData');
      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User token is missing.");
      }

      final Map<String, dynamic> userData = jsonDecode(userDataString);
      String? token = userData['accessToken'] ?? userData['data']?[0]?['access_token'];
      if (token == null) throw Exception("Token not found");

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(response.body);
        final serviceData = ServiceModel.fromJson(res);
        state = serviceData;
        
        _hasFetched = true;
      } else {
        throw Exception("Failed to load services");
      }
    } finally {
      loadingState.state = false;
    }
  }

  void reset() => _hasFetched = false;
}


// Define productProvider with ref
final serviceProvider = StateNotifierProvider<Serviceprovider, ServiceModel>((
  ref,
) {
  return Serviceprovider(ref);
});
