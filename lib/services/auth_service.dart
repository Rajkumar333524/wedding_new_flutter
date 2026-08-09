import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ============================================================
  // BACKEND
  // ============================================================

  static const String baseUrl =
      'https://wedding-new-backend.onrender.com';

  static const String _sessionKey = 'wedding_user_session';
  static const String _tokenKey = 'wedding_access_token';

  static String? _user;
  static String? _accessToken;

  // ============================================================
  // INIT
  // ============================================================

  static Future<void> init() async {
    final pref = await SharedPreferences.getInstance();

    _user = pref.getString(_sessionKey);
    _accessToken = pref.getString(_tokenKey);
  }

  // ============================================================
  // STATUS
  // ============================================================

  static bool isLoggedIn() {
    return _user != null && _accessToken != null;
  }

  static String? get currentUser => _user;

  static String? get accessToken => _accessToken;

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<void> login(
    String phone,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone.trim(),
        'password': password,
      }),
    );

    Map<String, dynamic> data;

    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Invalid server response (${res.statusCode})',
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            data['error']?.toString() ??
            'Login failed',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'Login failed',
      );
    }

    _user = phone.trim();
    _accessToken = data['access']?.toString();

    final pref = await SharedPreferences.getInstance();

    await pref.setString(
      _sessionKey,
      _user!,
    );

    if (_accessToken != null &&
        _accessToken!.isNotEmpty) {
      await pref.setString(
        _tokenKey,
        _accessToken!,
      );
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<void> register(
    String phone,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone.trim(),
        'password': password,
      }),
    );

    Map<String, dynamic> data;

    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Invalid server response (${res.statusCode})',
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            data['error']?.toString() ??
            'Registration failed',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'Registration failed',
      );
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  static Future<void> forgot(
    String phone,
  ) async {
    throw Exception(
      'Forgot password is not available yet.',
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    _user = null;
    _accessToken = null;

    final pref = await SharedPreferences.getInstance();

    await pref.remove(_sessionKey);
    await pref.remove(_tokenKey);
  }

  // ============================================================
  // AUTH HEADER
  // ============================================================

  static Map<String, String> get authHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_accessToken != null &&
        _accessToken!.isNotEmpty) {
      headers['Authorization'] =
          'Bearer $_accessToken';
    }

    return headers;
  }
}