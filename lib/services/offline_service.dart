import 'package:hive/hive.dart';

import '../models/guest.dart';

class OfflineService {
  static const String boxName = 'guestBox';

  // ============================================================
  // INIT
  // ============================================================

  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Guest>(boxName);
    }
  }

  // ============================================================
  // BOX
  // ============================================================

  static Box<Guest> get _box {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception(
        'Guest Hive box is not initialized.',
      );
    }

    return Hive.box<Guest>(boxName);
  }

  // ============================================================
  // LOAD ALL GUESTS
  // ============================================================

  static List<Guest> loadGuests() {
    return _box.values.toList();
  }

  // ============================================================
  // ADD / UPDATE GUEST
  // ============================================================

  static Future<void> saveGuest(Guest guest) async {
    await _box.put(
      guest.localId,
      guest,
    );
  }

  // ============================================================
  // DELETE GUEST
  // ============================================================

  static Future<void> deleteGuest(int localId) async {
    await _box.delete(localId);
  }

  // ============================================================
  // CLEAR ALL DATA
  // ============================================================

  static Future<void> clearAll() async {
    await _box.clear();
  }

  // ============================================================
  // DASHBOARD CALCULATIONS
  // ============================================================

  static double totalGiven(int weddingId) {
    return loadGuests()
        .where(
          (guest) => guest.weddingId == weddingId,
        )
        .fold(
          0.0,
          (sum, guest) => sum + guest.given,
        );
  }

  static double totalTaken(int weddingId) {
    return loadGuests()
        .where(
          (guest) => guest.weddingId == weddingId,
        )
        .fold(
          0.0,
          (sum, guest) => sum + guest.taken,
        );
  }

  static int totalGuests(int weddingId) {
    return loadGuests()
        .where(
          (guest) => guest.weddingId == weddingId,
        )
        .length;
  }

  static double balance(int weddingId) {
    return totalGiven(weddingId) - totalTaken(weddingId);
  }

  // ============================================================
  // SEARCH
  // ============================================================

  static List<Guest> searchGuests(
    String query,
    int weddingId,
  ) {
    final q = query.trim().toLowerCase();

    return loadGuests()
        .where(
          (guest) =>
              guest.weddingId == weddingId &&
              (
                guest.nameEn.toLowerCase().contains(q) ||
                guest.nameHi.toLowerCase().contains(q) ||
                guest.addressEn.toLowerCase().contains(q) ||
                guest.addressHi.toLowerCase().contains(q)
              ),
        )
        .toList();
  }

  // ============================================================
  // BACKUP
  // ============================================================

  static List<Map<String, dynamic>> exportBackup() {
    return loadGuests()
        .map(
          (guest) => guest.toJson(),
        )
        .toList();
  }

  // ============================================================
  // RESTORE BACKUP
  // ============================================================

  static Future<void> importBackup(
    List<Map<String, dynamic>> data,
  ) async {
    for (final json in data) {
      final guest = Guest.fromJson(json);

      await _box.put(
        guest.localId,
        guest,
      );
    }
  }
}