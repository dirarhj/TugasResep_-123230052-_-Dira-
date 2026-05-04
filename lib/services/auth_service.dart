import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKey = 'username';
  static const String _passKey = 'password';
  static const String _isLoginKey = 'isLoggedIn';

  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, username);
    await prefs.setString(_passKey, password);
    return true; 
  }

  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUser = prefs.getString(_userKey);
    String? savedPass = prefs.getString(_passKey);

    if (username == savedUser && password == savedPass) {
      await prefs.setBool(_isLoginKey, true);
      return true; 
    }
    return false; 
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoginKey); 
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoginKey) ?? false;
  }
}