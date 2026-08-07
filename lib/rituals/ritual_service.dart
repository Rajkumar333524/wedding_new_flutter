import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RitualService {

  static const _paupujiKey = 'paupuji_table';
  static const _groomKey   = 'groom_table';

  // ===== PAUPUJI =====

  static Future<List<Map<String, dynamic>>> loadPaupuji() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_paupujiKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  static Future<void> savePaupujiEntry({
    required String name,
    required String item,
    required double money,
  }) async {
    final table = await loadPaupuji();
    table.add({
      'name': name,
      'item': item,
      'money': money,
      'time': DateTime.now().toIso8601String(),
    });

    final p = await SharedPreferences.getInstance();
    await p.setString(_paupujiKey, jsonEncode(table));
  }

  static Future<void> deletePaupuji(int index) async {
    final table = await loadPaupuji();
    table.removeAt(index);

    final p = await SharedPreferences.getInstance();
    await p.setString(_paupujiKey, jsonEncode(table));
  }

  // ===== GROOM =====

  static Future<List<Map<String, dynamic>>> loadGroom() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_groomKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  static Future<void> saveGroomEntry({
    required String name,
    required String gift,
    required double money,
  }) async {
    final table = await loadGroom();
    table.add({
      'name': name,
      'gift': gift,
      'money': money,
      'time': DateTime.now().toIso8601String(),
    });

    final p = await SharedPreferences.getInstance();
    await p.setString(_groomKey, jsonEncode(table));
  }

  static Future<void> deleteGroom(int index) async {
    final table = await loadGroom();
    table.removeAt(index);

    final p = await SharedPreferences.getInstance();
    await p.setString(_groomKey, jsonEncode(table));
  }
}
