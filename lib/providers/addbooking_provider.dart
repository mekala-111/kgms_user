// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kgms_user/providers/auth_state.dart';
// import 'package:kgms_user/utils/gomed_api.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/retry.dart';
// import '../model/addbooking.dart';

// class BookingProvider extends StateNotifier<BookingModel> {
//   final Ref ref;

//   BookingProvider(this.ref) : super(BookingModel.initial());

//   Future<void> createBooking({
//     required String? userId,
//     required List<String> productIds,
//     required String location,
//     required String? address,
//   }) async {
// print('inside create booking....$userId,$productIds,$location,$address');
//     try {
//       // Retrieve token from SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       String? userDataString = prefs.getString('userData');

//       if (userDataString == null || userDataString.isEmpty) {
//         throw Exception("User token is missing. Please log in again.");
//       }

//       final Map<String, dynamic> userData = jsonDecode(userDataString);
//       String? token = userData['accessToken'];

//       if (token == null || token.isEmpty) {
//         token = userData['data'] != null &&
//                 (userData['data'] as List).isNotEmpty &&
//                 userData['data'][0]['access_token'] != null
//             ? userData['data'][0]['access_token']
//             : null;
//       }

//       if (token == null || token.isEmpty) {
//         throw Exception("User token is invalid. Please log in again.");
//       }

//       print('Retrieved Token: $token');

//       // Initialize retry logic
//       final client = RetryClient(
//         http.Client(),
//         retries: 3,
//         when: (response) => response.statusCode == 400 || response.statusCode == 401,
//         onRetry: (req, res, retryCount) async {
//           if (retryCount == 0 && (res?.statusCode == 400 || res?.statusCode == 401)) {
//             // Token refresh logic
//             String? newAccessToken = await ref.read(userProvider.notifier).restoreAccessToken();
//             print('Restored Token: $newAccessToken');
//             req.headers['Authorization'] = 'Bearer $newAccessToken';
//           }
//         },
//       );
//        // Prepare request body
//       final Map<String, dynamic> requestBody = {
//         "userId": userId ?? '',
//         "location": location,
//         "address": address ?? '',
//         "status": "pending",
//         "productIds": productIds,
//       };

//        // Send POST request with JSON body
//       final response = await client.post(
//         Uri.parse(Bbapi.createbooking),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(requestBody),
//       );

//     // Send Request
//     // final streamedResponse = await client.send(request);
//     // final response = await http.Response.fromStream(streamedResponse);

//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final Map<String, dynamic> responseBody = jsonDecode(response.body);
//         state = BookingModel.fromJson(responseBody);
//         print("Booking created successfully!");
//       } else {
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['message'] ?? 'Unexpected error occurred.';
//         throw Exception("Error creating booking: $errorMessage");
//       }
//     } catch (error) {
//       print("Failed to create booking: $error");
//       rethrow;
//     }
//   }
// }

// final bookingProvider = StateNotifierProvider<BookingProvider, BookingModel>((ref) {
//   return BookingProvider(ref);
// });
