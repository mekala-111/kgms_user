import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgms_user/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutNotifier extends StateNotifier<AsyncValue<void>> {
  LogoutNotifier() : super(const AsyncValue.data(null));


  
  Future<void> logout(BuildContext context) async {
 
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data
      // Navigate to the LoginScreen
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  Future<void> clearUserData() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final logoutProvider = StateNotifierProvider<LogoutNotifier, AsyncValue<void>>(
      (ref) => LogoutNotifier(),
);