import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/providers/loader.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:kgms_user/model/product.dart';
import 'package:kgms_user/utils/gomed_api.dart';
import 'package:kgms_user/providers/auth_state.dart';

class ProductProvider extends StateNotifier<ProductModel> {
  final Ref ref;
  bool _hasFetched = false;

  ProductProvider(this.ref) : super(ProductModel.initial());

  Future<void> fetchProducts() async {
    if (_hasFetched && state.data != null && state.data!.isNotEmpty) {
      return; // Skip API call if already fetched
    }

    final loadingState = ref.read(loadingProvider.notifier);
    final loginprovider = ref.read(userProvider);
    final token = loginprovider.data?[0].accessToken;

    try {
      if (token == null || token.isEmpty) {
        throw Exception('Authorization token is missing');
      }

      loadingState.state = true;

      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) => response.statusCode == 401,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await ref
                .watch(userProvider.notifier)
                .restoreAccessToken();
            req.headers['Authorization'] = "Bearer $accessToken";
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
        final Map<String, dynamic> res = json.decode(response.body);
        final productData = ProductModel.fromJson(res);
        state = productData;
       
        _hasFetched = true;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } finally {
      loadingState.state = false;
    }
  }

  /// Call this to force the next fetch to re-fetch from API
  void reset() {
    _hasFetched = false;
  }
}

final productProvider =
    StateNotifierProvider<ProductProvider, ProductModel>((ref) {
  return ProductProvider(ref);
});
