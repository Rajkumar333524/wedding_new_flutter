import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/wedding.dart';
import '../models/guest.dart';
import '../models/taken_money.dart';
import 'auth_service.dart';

class ApiService {
  // ============================================================
  // BACKEND URL
  // ============================================================

  static const String baseUrl =
      'https://wedding-new-backend.onrender.com';

  // ============================================================
  // COMMON RESPONSE HANDLER
  // ============================================================

  static Future<Map<String, dynamic>> _handleResponse(
  http.Response res,
) async {
  // ============================================================
  // SESSION EXPIRED / UNAUTHORIZED
  // ============================================================

  if (res.statusCode == 401) {
    await AuthService.logout();

    throw Exception(
      'Session expired. Please login again.',
    );
  }

  // ============================================================
  // SUCCESS RESPONSE
  // ============================================================

  if (res.statusCode >= 200 && res.statusCode < 300) {
    if (res.body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  String message = res.body;

  try {
    final decoded = jsonDecode(res.body);

    if (decoded is Map && decoded['message'] != null) {
      message = decoded['message'].toString();
    } else if (decoded is Map && decoded['error'] != null) {
      message = decoded['error'].toString();
    }
  } catch (_) {}

  throw Exception(
    'Server error ${res.statusCode}: $message',
  );
}
  // ============================================================
  // TEST BACKEND
  // ============================================================

  static Future<Map<String, dynamic>> testApi() async {
    final res = await http.get(
      Uri.parse('$baseUrl/test_api/'),
    );

    return _handleResponse(res);
  }

  // ============================================================
  // WEDDINGS
  // ============================================================

  static Future<List<Wedding>> getWeddings() async {
    final res = await http.get(
      Uri.parse('$baseUrl/get_weddings/'),
      headers: AuthService.authHeaders,
    );

    final decoded = await _handleResponse(res);

    final List data = decoded['weddings'] is List
        ? decoded['weddings']
        : [];

    return data
        .map(
          (e) => Wedding.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  static Future<void> addWeddingObject(
    Wedding wedding,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/add_wedding/'),
      headers: AuthService.authHeaders,
      body: jsonEncode(
        wedding.toJson(),
      ),
    );

    await _handleResponse(res);
  }

  static Future<void> deleteWedding(
    int id,
  ) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/delete_wedding/$id/'),
      headers: AuthService.authHeaders,
    );

    await _handleResponse(res);
  }

  // ============================================================
  // GUESTS
  // ============================================================

  static Future<List<Guest>> getGuests(
    int weddingId,
  ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/get_guests/$weddingId/'),
      headers: AuthService.authHeaders,
    );

    final decoded = await _handleResponse(res);

    final List data = decoded['guests'] is List
        ? decoded['guests']
        : [];

    return data
        .map(
          (e) => Guest.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  static Future<Guest> addGuest(
  Guest guest,
) async {
  final res = await http.post(
    Uri.parse('$baseUrl/add_guest/'),
    headers: AuthService.authHeaders,
    body: jsonEncode(
      guest.toJson(),
    ),
  );

  final decoded = await _handleResponse(res);

  final guestData = decoded['guest'];

  if (guestData is! Map) {
    throw Exception('Invalid guest response from server');
  }

  final serverGuest = Guest.fromJson(
    Map<String, dynamic>.from(guestData),
  );

  return serverGuest.copyWith(
    localId: guest.localId,
  );
}
  static Future<void> updateGuest(
    Guest guest,
  ) async {
    if (guest.backendId <= 0) {
      throw Exception(
        'Invalid guest backend ID',
      );
    }

    final res = await http.put(
      Uri.parse(
        '$baseUrl/update_guest/${guest.backendId}/',
      ),
      headers: AuthService.authHeaders,
      body: jsonEncode(
        guest.toJson(),
      ),
    );

    await _handleResponse(res);
  }

 static Future<void> deleteGuest(
  int id,
) async {
  if (id <= 0) {
    throw Exception(
      'Invalid guest ID',
    );
  }

  final res = await http.delete(
    Uri.parse(
      '$baseUrl/delete_guest/$id/',
    ),
    headers: AuthService.authHeaders,
  );

  await _handleResponse(res);
}
  // ============================================================
  // TAKEN MONEY
  // ============================================================

  static Future<List<TakenMoney>> getTakenMoney(
    int weddingId,
  ) async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/get_taken_money/$weddingId/',
      ),
      headers: AuthService.authHeaders,
    );

    final decoded = await _handleResponse(res);

    final List data = decoded['money'] is List
        ? decoded['money']
        : [];

    return data
        .map(
          (e) => TakenMoney.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  static Future<void> addTakenMoney(
    TakenMoney money,
  ) async {
    final res = await http.post(
      Uri.parse(
        '$baseUrl/add_taken_money/',
      ),
     headers: AuthService.authHeaders,
      body: jsonEncode(
        money.toJson(),
      ),
    );

    await _handleResponse(res);
  }

  static Future<void> deleteTakenMoney(
    int id,
  ) async {
    if (id <= 0) {
      throw Exception(
        'Invalid taken money ID',
      );
    }

    final res = await http.delete(
      Uri.parse(
        '$baseUrl/delete_taken_money/$id/',
      ),
       headers: AuthService.authHeaders,
    );

    await _handleResponse(res);
  }
}
