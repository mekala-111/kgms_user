import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:kgms_user/model/product.dart'; // Import your model file
import 'package:kgms_user/utils/gomed_api.dart'; // Import Bbapi class
import 'package:kgms_user/providers/auth_state.dart';

class ProductProvider extends StateNotifier<ProductModel> {
  final Ref ref; // To access other providers
  ProductProvider(this.ref) : super((ProductModel.initial()));

  Future<void> fetchProducts() async {
    final loadingState = ref.read(loadingProvider.notifier);
    final loginprovider = ref.read(userProvider);
    final token = loginprovider.data?[0].accessToken;
    try {
      //final prefs = await SharedPreferences.getInstance();
      //String? token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        throw Exception('Authorization token is missing');
      }
      loadingState.state = true; // Show loading state
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            // Here, handle your token restoration logic
            // You can access other providers using ref.read if needed
            var accessToken = await ref
                .watch(userProvider.notifier)
                .restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = "Bearer ${accessToken.toString()}";
          }
        },
      );

      final response = await client.get(
        Uri.parse(Bbapi.getProducts),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Attempt to parse the response body
        final Map<String, dynamic> res = json.decode(response.body);
        final productData = ProductModel.fromJson(res);
        state = productData;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } finally {
      loadingState.state = false; // Hide loading state
    }
  }
}

// Define productProvider with ref
final productProvider = StateNotifierProvider<ProductProvider, ProductModel>((
  ref,
) {
  return ProductProvider(ref);
});
