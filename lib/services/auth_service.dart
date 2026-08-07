import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {

  static const String base = "http://YOUR_SERVER_IP/wedding_api";
  static const String _sessionKey = "wedding_user_session";

  static String? _user;

  // 🔁 Init at app start
  static Future<void> init() async {
    final pref = await SharedPreferences.getInstance();
    _user = pref.getString(_sessionKey);
  }

  // 🧠 Status
  static bool isLoggedIn() => _user != null;
  static String? get currentUser => _user;

  // 🔐 Login
  static Future<void> login(String phone, String password) async {
    final res = await http.post(
      Uri.parse("$base/login.php"),
      body: {"phone": phone, "password": password},
    );

    final data = jsonDecode(res.body);

    if (data['success'] != true) {
      throw data['message'] ?? "Login failed";
    }

    _user = phone;
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_sessionKey, phone);
  }

  // 🆕 Register
  static Future<void> register(String phone, String password) async {
    final res = await http.post(
      Uri.parse("$base/register.php"),
      body: {"phone": phone, "password": password},
    );

    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw data['message'] ?? "Registration failed";
    }
  }

  // 🔁 Forgot Password
  static Future<void> forgot(String phone) async {
    final res = await http.post(
      Uri.parse("$base/forgot.php"),
      body: {"phone": phone},
    );

    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw data['message'] ?? "Reset failed";
    }
  }

  // 🚪 Logout
  static Future<void> logout() async {
    _user = null;
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_sessionKey);
  }
}
