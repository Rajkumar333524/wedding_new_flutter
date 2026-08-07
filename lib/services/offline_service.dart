import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/guest.dart';

class OfflineService {
  static const String boxName = "guestBox";

  // 🔹 App start pe call
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  // 📥 Load all guests
  static List<Guest> loadGuests() {
    final box = Hive.box(boxName);
    return box.values
        .map((e) => Guest.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
  }

  // ➕ Add / Update guest
  static void saveGuest(Guest g) {
    final box = Hive.box(boxName);
    box.put(g.id, jsonEncode(g.toJson()));
  }

  // 🗑 Delete guest
  static void deleteGuest(int id) {
    final box = Hive.box(boxName);
    box.delete(id);
  }

  // 🧹 Clear all data (Reset)
  static void clearAll() {
    final box = Hive.box(boxName);
    box.clear();
  }

  // 📊 Dashboard calculations
  static double totalGiven(int weddingId) {
    return loadGuests()
        .where((g) => g.weddingId == weddingId)
        .fold(0, (s, g) => s + g.given);
  }

  static double totalTaken(int weddingId) {
    return loadGuests()
        .where((g) => g.weddingId == weddingId)
        .fold(0, (s, g) => s + g.taken);
  }

  static int totalGuests(int weddingId) {
    return loadGuests()
        .where((g) => g.weddingId == weddingId)
        .length;
  }

  static double balance(int weddingId) {
    return totalGiven(weddingId) - totalTaken(weddingId);
  }

  // 🔍 Search (Hindi + English)
  static List<Guest> searchGuests(String query, int weddingId) {
    final q = query.toLowerCase();
    return loadGuests().where((g) =>
        g.weddingId == weddingId &&
        (g.nameEn.toLowerCase().contains(q) ||
         g.nameHi.toLowerCase().contains(q) ||
         g.addressEn.toLowerCase().contains(q) ||
         g.addressHi.toLowerCase().contains(q))
    ).toList();
  }

  // 📦 Backup
  static List<Map<String, dynamic>> exportBackup() {
    return loadGuests().map((g) => g.toJson()).toList();
  }

  // ♻ Restore
  static void importBackup(List<Map<String, dynamic>> data) {
    final box = Hive.box(boxName);
    for (var g in data) {
      final guest = Guest.fromJson(g);
      box.put(guest.id, jsonEncode(guest.toJson()));
    }
  }
}
