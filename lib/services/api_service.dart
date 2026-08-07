import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/wedding.dart';
import '../models/guest.dart';
import '../models/taken_money.dart';

class ApiService {

  // 🔗 Backend URL
  static const String baseUrl = "https://wedding-new-backend.onrender.com";
  // =================== COMMON ===================

  static Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      try {
        return jsonDecode(res.body);
      } catch (_) {
        return {};
      }
    } else {
      throw Exception("Server error ${res.statusCode}: ${res.body}");
    }
  }

  // =================== WEDDINGS ===================

  static Future<List<Wedding>> getWeddings() async {
    final res = await http.get(Uri.parse("$baseUrl/get_weddings/"));
    final decoded = await _handleResponse(res);

    final List data = (decoded['weddings'] ?? []) as List;
    return data.map((e) => Wedding.fromJson(e)).toList();
  }

  static Future<void> addWeddingObject(Wedding wedding) async {
    final res = await http.post(
      Uri.parse("$baseUrl/add_wedding/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(wedding.toJson()),
    );

    await _handleResponse(res);
  }

  static Future<void> deleteWedding(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/delete_wedding/$id/"));
    await _handleResponse(res);
  }

  // =================== GUESTS ===================

  static Future<List<Guest>> getGuests(int weddingId) async {
    final res = await http.get(Uri.parse("$baseUrl/get_guests/$weddingId/"));
    final decoded = await _handleResponse(res);

    final List data = (decoded['guests'] ?? []) as List;
    return data.map((e) => Guest.fromJson(e)).toList();
  }

  static Future<void> addGuest(Guest guest) async {
    final res = await http.post(
      Uri.parse("$baseUrl/add_guest/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(guest.toJson()),
    );

    await _handleResponse(res);
  }

  static Future<void> updateGuest(Guest guest) async {
    final res = await http.put(
      Uri.parse("$baseUrl/update_guest/${guest.id}/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(guest.toJson()),
    );

    await _handleResponse(res);
  }

  static Future<void> deleteGuest(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/delete_guest/$id/"));
    await _handleResponse(res);
  }

  // =================== MONEY ===================

  static Future<List<TakenMoney>> getTakenMoney(int weddingId) async {
    final res =
        await http.get(Uri.parse("$baseUrl/get_taken_money/$weddingId/"));

    final decoded = await _handleResponse(res);

    final List data = (decoded['money'] ?? []) as List;
    return data.map((e) => TakenMoney.fromJson(e)).toList();
  }

  static Future<void> addTakenMoney(TakenMoney money) async {
    final res = await http.post(
      Uri.parse("$baseUrl/add_taken_money/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(money.toJson()),
    );

    await _handleResponse(res);
  }

  static Future<void> deleteTakenMoney(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/delete_taken_money/$id/"));
    await _handleResponse(res);
  }
}
