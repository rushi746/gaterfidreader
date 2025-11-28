import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/appstorage.dart';

final splashControllerProvider =
    StateNotifierProvider<SplashController, AsyncValue<bool>>(
  (ref) => SplashController(),
);

class SplashController extends StateNotifier<AsyncValue<bool>> {
  SplashController() : super(const AsyncValue.loading()) {
    print("SplashController initialized ------------------------");
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    print("Checking login status... Waiting 2 seconds splash delay 🕒");

    await Future.delayed(const Duration(seconds: 2));

    try {
      final result = AppStorage.getLoginResult();

      print("Raw GetStorage result: $result");
      print("Type of result: ${result.runtimeType}");

      /// Convert string to bool explicitly
      final bool isLoggedIn = result.toString() == "true";

      print("Login status evaluated: $isLoggedIn");

      state = AsyncValue.data(isLoggedIn);

      print("State updated: $state");
    } catch (e) {
      print("Error reading saved login state ❌: $e");
      state = const AsyncValue.data(false);
    }

    print("End of login status check ------------------------------");
  }
}
