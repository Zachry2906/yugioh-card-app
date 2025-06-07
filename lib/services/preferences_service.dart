import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _lastViewedCardKey = 'last_viewed_card_id';
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';

  // Last viewed card
  static Future<void> setLastViewedCardId(int cardId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastViewedCardKey, cardId);
  }

  static Future<int?> getLastViewedCardId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastViewedCardKey);
  }

  // Theme settings
  static Future<void> setThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }

  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  // Notification settings
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Clear all preferences
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
