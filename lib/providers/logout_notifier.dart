import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutNotifier extends StateNotifier<AsyncValue<void>> {
  LogoutNotifier() : super(const AsyncValue.data(null));

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