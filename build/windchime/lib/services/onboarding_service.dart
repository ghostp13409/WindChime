import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _firstTimeKey = 'is_first_time_user';

  /// Check if this is the user's first time opening the app
  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  /// Mark that the user has completed the welcome screen
  static Future<void> markWelcomeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
  }

  /// Reset the onboarding state (useful for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstTimeKey);
  }
}
