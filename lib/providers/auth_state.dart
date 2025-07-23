import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/model/auth.dart';
import 'package:kgms_user/screens/home_page.dart';
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // Added: Import for MediaType
import 'firebase_auth.dart';
import 'loader.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kgms_user/utils/gomed_api.dart';

class PhoneAuthNotifier extends StateNotifier<UserModel> {
  final Ref ref;
  PhoneAuthNotifier(this.ref) : super(UserModel.initial());

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if the 'userData' key exists in SharedPreferences
    if (!prefs.containsKey('userData')) {
      return false;
    }

    try {
      // Retrieve and decode the user data from SharedPreferences
      final extractedData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

      // Validate that all necessary keys exist in the extracted data
      if (extractedData.containsKey('statusCode') &&
          extractedData.containsKey('success') &&
          extractedData.containsKey('messages') &&
          extractedData.containsKey('data')) {
        // Map the JSON data to the UserModel
        final userModel = UserModel.fromJson(extractedData);

        // Validate nested data structure
        if (userModel.data != null && userModel.data!.isNotEmpty) {
          final firstData =
              userModel.data![0]; // Access the first element in the list
          if (firstData.user == null || firstData.accessToken == null) {
            return false;
          }
        }

        // Update the state with the decoded user data
        state = state.copyWith(
          statusCode: userModel.statusCode,
          success: userModel.success,
          messages: userModel.messages,
          data: userModel.data,
        );

        // Accessing User ID from the first Data object
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Log the error for debugging purposes
      debugPrint('Error in tryAutoLogin: $e');
      return false;
    }
  }

  Future<bool> updateProfile(
    String? name,
    String? email,
    String? phone,
    String? address,
    double? lat,
    double? lng,
    File? selectedImage,
    WidgetRef ref,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userModel = ref.read(
      userProvider,
    ); // Retrieve UserModel from the provider
    final userId = userModel
        .data?[0]
        .user!
        .sId; // Get user ID, default to empty string if null
    final token = userModel
        .data?[0]
        .accessToken; // Get token, default to empty string if null
    final loadingState = ref.read(loadingProvider.notifier);

    if (userId == null || token == null) {
      return false;
    }

    final apiUrl = "${Bbapi.updateProfile}/$userId";

    try {
      loadingState.state = true; // Show loading state
      final retryClient = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 404 || response.statusCode == 401
              ? true
              : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 404 ||
              res?.statusCode == 401) {
            // Here, handle your token restoration logic
            // You can access other providers using ref.read if needed
            var accessToken = await restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = "Bearer ${accessToken.toString()}";
          }
        },
      );
      final request = http.MultipartRequest('PUT', Uri.parse(apiUrl))
        ..headers.addAll({
          "Authorization": "Bearer $token",
          "Content-Type": "multipart/form-data",
        })
        ..fields['name'] = name ?? ''
        ..fields['email'] = email ?? ''
        ..fields['mobile'] = phone ?? ''
        ..fields['address'] = address ?? ''
        ..fields['longitude'] = (lng ?? 0.0).toString()
        ..fields['latitude'] = (lat ?? 0.0).toString()
        ..fields['role'] = 'user';

      if (selectedImage != null) {
        if (await selectedImage.exists()) {
          final fileExtension = selectedImage.path
              .split('.')
              .last
              .toLowerCase();
          final contentType = MediaType(
            'image',
            fileExtension,
          ); // Determine content type dynamically

          request.files.add(
            await http.MultipartFile.fromPath(
              'profileImage',
              selectedImage.path,
              contentType: contentType,
            ),
          );
        } else {
          throw Exception("Profile image file not found");
        }
      }

      // Send the request using the inner client of RetryClient
      final streamedResponse = await retryClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var userDetails = json.decode(response.body);
        UserModel user = UserModel.fromJson(userDetails);

        state = user;
        final userData = json.encode({
          'statusCode': user.statusCode,
          'success': user.success,
          'messages': user.messages,
          'data': user.data
              ?.map((data) => data.toJson())
              .toList(), // Serialize all Data objects
        });

        await prefs.setString('userData', userData);
        return true;
      } else {
        debugPrint('Profile update failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      loadingState.state = false; // Hide loading state
    }
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final auth = ref.read(firebaseAuthProvider);
    var loader = ref.read(loadingProvider.notifier);
    var codeSentNotifier = ref.read(codeSentProvider.notifier);
    var pref = await SharedPreferences.getInstance();

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await auth.signInWithCredential(credential);
            // Log success instead of using context in async callback
            debugPrint("Phone number automatically verified");
          } catch (e, stackTrace) {
            FirebaseCrashlytics.instance.recordError(
              e,
              stackTrace,
              reason: "Error during automatic sign-in with credential",
            );
            debugPrint("Auto sign-in failed: $e");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          // Record FirebaseAuthException in Crashlytics
          FirebaseCrashlytics.instance.recordError(
            e,
            null,
            reason: "Phone number verification failed",
            fatal: false,
          );

          String errorMsg = 'Verification failed.';
          if (e.code == 'invalid-phone-number') {
            errorMsg = 'The phone number is invalid.';
          } else if (e.message != null) {
            errorMsg = e.message!;
          }

          // Log error instead of using context in async callback
          debugPrint("Verification failed: $errorMsg");
        },
        codeSent: (String verificationId, int? resendToken) {
          pref.setString("verificationid", verificationId);
          codeSentNotifier.state = true;
          // Log success instead of using context in async callback
          debugPrint("OTP sent successfully");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Log timeout instead of using context in async callback
          debugPrint("Auto retrieval timeout. Please enter OTP manually.");
        },
      );
    } catch (e, stackTrace) {
      loader.state = false;

      // Record unexpected error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: "Unexpected error during phone number verification",
        fatal: true,
      );

      debugPrint("Error during verification: $e");
    }
  }

  // Safe method to show snackbar with context validation
  /* void _showSnackBarSafe(BuildContext context, String message, Color backgroundColor) {
    try {
      // Validate that the context is still valid before using it
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
          ),
        );
      }
    } catch (e) {
      // If context is invalid, just log the message
      debugPrint('Unable to show snackbar: $message');
    }
  }*/

  Future<void> signInWithPhoneNumber(
    String smsCode,
    WidgetRef ref,
    BuildContext context,
  ) async {
    // Store context reference before async operations
    final currentContext = context;

    final authState = ref.watch(firebaseAuthProvider);
    final loadingState = ref.watch(loadingProvider.notifier);
    var pref = await SharedPreferences.getInstance();
    String? verificationid = pref.getString('verificationid');

    try {
      loadingState.state = true;

      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationid!,
        smsCode: smsCode,
      );

      await authState.signInWithCredential(credential).then((value) async {
        if (value.user != null) {
          // Send phone number and role to API
          final success = await sendPhoneNumberAndRoleToAPI(
            phoneNumber: value.user!.phoneNumber!,
            role: "user", // Assign the role as needed
          );

          // Handle navigation outside of the StateNotifier
          if (success && currentContext.mounted) {
            Navigator.pushReplacement(
              currentContext,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }
      });

      loadingState.state = false;
    } catch (e) {
      debugPrint('Error during sign in with phone number: $e');
      loadingState.state = false;
    } finally {
      loadingState.state = false;
    }
  }

  // Modified to return success/failure instead of handling navigation
  Future<bool> sendPhoneNumberAndRoleToAPI({
    required String phoneNumber,
    required String role,
  }) async {
    const String apiUrl = Bbapi.login; // Replace with your API URL

    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_API_TOKEN", // Add token if needed
        },
        body: json.encode({
          "mobile": phoneNumber.toString(),
          "role": role.toString(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var userDetails = json.decode(response.body);
        UserModel user = UserModel.fromJson(userDetails);

        state = user;
        final userData = json.encode({
          'statusCode': user.statusCode,
          'success': user.success,
          'messages': user.messages != null
              ? List<String>.from(user.messages!)
              : [],
          'data': user.data?.map((data) => data.toJson()).toList(),
        });

        await prefs.setString('userData', userData);
        return true; // Return success
      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending phone number to API: $e');
      return false;
    }
  }

  Future<String> generateUniqueUid() async {
    Random random = Random();
    String uniqueUid;

    // Generate a random 6-digit UID
    int randomNumber =
        100000 + random.nextInt(900000); // Range: 100000 to 999999
    uniqueUid = "$randomNumber#";

    return uniqueUid;
  }

  Future<void> deleteAccount(String? userId, String? token) async {
    final String apiUrl =
        "${Bbapi.deleteAccount}/$userId"; // Replace with your API URL for delete account
    final loadingState = ref.read(loadingProvider.notifier);

    try {
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
            var accessToken = await restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = accessToken.toString();
          }
        },
      );
      final response = await client.delete(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Include the token
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optionally, clear local user data (e.g., shared preferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Navigate to a different screen (e.g., login or onboarding)
      } else {
        debugPrint('Delete account failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
    } finally {
      loadingState.state = false; // Hide loading state
    }
  }

  Future<String> restoreAccessToken() async {
    const url = Bbapi.refreshToken;

    final prefs = await SharedPreferences.getInstance();

    try {
      // Retrieve stored user data
      String? storedUserData = prefs.getString('userData');
      if (storedUserData == null) {
        throw Exception("No stored user data found.");
      }

      UserModel user = UserModel.fromJson(json.decode(storedUserData));
      String? currentRefreshToken = user.data?.isNotEmpty == true
          ? user.data![0].refreshToken
          : null;
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw Exception("No valid refresh token found.");
      }

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $currentRefreshToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({"refresh_token": currentRefreshToken}),
      );

      var userDetails = json.decode(response.body);
      switch (response.statusCode) {
        case 401:
          // Handle 401 Unauthorized
          debugPrint('Unauthorized: Refresh token expired or invalid');
          break;
        case 200:
          // Extract the new access token and refresh token
          final newAccessToken = userDetails['data']['access_token'];
          final newRefreshToken = userDetails['data']['refresh_token'];

          // Retrieve existing user data from SharedPreferences
          String? storedUserData = prefs.getString('userData');

          if (storedUserData != null) {
            // Parse the stored user data into a UserModel object
            UserModel user = UserModel.fromJson(json.decode(storedUserData));

            // Update the accessToken and refreshToken in the existing data model
            user = user.copyWith(
              data: [
                user.data![0].copyWith(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                ),
              ],
            );
            // Convert the updated UserModel back to JSON
            final updatedUserData = json.encode({
              'statusCode': user.statusCode,
              'success': user.success,
              'messages': user.messages,
              'data': user.data?.map((data) => data.toJson()).toList(),
            });

            // Save the updated user data in SharedPreferences
            await prefs.setString('userData', updatedUserData);

            return newAccessToken; // Return the new access token
          } else {
            // Handle the case where there is no existing user data in SharedPreferences
            debugPrint('No existing user data found in SharedPreferences');
          }
          break;
        default:
          debugPrint(
            'Token refresh failed with status: ${response.statusCode}',
          );
          break;
      }
    } on FormatException catch (e) {
      debugPrint('Format exception during token refresh: $e');
    } on HttpException catch (e) {
      debugPrint('HTTP exception during token refresh: $e');
    } catch (e) {
      debugPrint('Error during token refresh: $e');
      if (e is Error) {
        debugPrint('Stack trace: ${e.stackTrace}');
      }
    }
    return ''; // Return empty string in case of any error
  }
}

final userProvider = StateNotifierProvider<PhoneAuthNotifier, UserModel>((ref) {
  return PhoneAuthNotifier(ref);
});
