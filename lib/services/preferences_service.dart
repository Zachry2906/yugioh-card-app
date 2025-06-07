import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static const String _searchHistoryKey = 'search_history';
  static const String _themeKey = 'theme_mode';
  static const String _lastViewedCardKey = 'last_viewed_card';
  static const String _userPreferencesKey = 'user_preferences';

  // Search History
  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_searchHistoryKey) ?? [];
    return historyJson;
  }

  static Future<void> addToSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();
    
    // Remove if already exists to avoid duplicates
    history.remove(query);
    history.insert(0, query);
    if (history.length > 10) {
      history = history.take(10).toList();
    }
    
    await prefs.setStringList(_searchHistoryKey, history);
  }

  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }

  // Theme
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  // Last Viewed Card
  static Future<int?> getLastViewedCardId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastViewedCardKey);
  }

  static Future<void> setLastViewedCardId(int cardId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastViewedCardKey, cardId);
  }

  // User Preferences
  static Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString(_userPreferencesKey);
    if (prefsJson != null) {
      return json.decode(prefsJson);
    }
    return {
      'show_card_details': true,
      'auto_save_favorites': true,
      'notification_enabled': true,
    };
  }

  static Future<void> setUserPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPreferencesKey, json.encode(preferences));
  }

  // Specific preference getters/setters
  static Future<bool> getShowCardDetails() async {
    final prefs = await getUserPreferences();
    return prefs['show_card_details'] ?? true;
  }

  static Future<void> setShowCardDetails(bool show) async {
    final prefs = await getUserPreferences();
    prefs['show_card_details'] = show;
    await setUserPreferences(prefs);
  }
}