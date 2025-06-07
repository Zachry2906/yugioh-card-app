import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _username;
  String? _encryptedPassword;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;

  // Check if user is already logged in
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _username = prefs.getString('username');
    _encryptedPassword = prefs.getString('encrypted_password');
    
    notifyListeners();
    return _isLoggedIn;
  }

  // Login user
  Future<void> login(String username, String encryptedPassword) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('username', username);
    await prefs.setString('encrypted_password', encryptedPassword);
    await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    _isLoggedIn = true;
    _username = username;
    _encryptedPassword = encryptedPassword;
    
    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('is_logged_in');
    await prefs.remove('username');
    await prefs.remove('encrypted_password');
    await prefs.remove('login_timestamp');
    
    _isLoggedIn = false;
    _username = null;
    _encryptedPassword = null;
    
    notifyListeners();
  }

  // Get login duration
  Future<Duration> getLoginDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimestamp = prefs.getInt('login_timestamp') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return Duration(milliseconds: now - loginTimestamp);
  }
}
