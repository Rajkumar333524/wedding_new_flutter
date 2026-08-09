import 'package:hive/hive.dart';

import '../models/guest.dart';

class HiveService {
  static const String _boxName = 'guestBox';

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE HIVE
  // ============================================================

  static Future<void> init() async {
    if (_initialized && Hive.isBoxOpen(_boxName)) {
      return;
    }

    // Register Guest adapter only once
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GuestAdapter());
    }

    // Open guest box
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Guest>(_boxName);
    }

    _initialized = true;
  }

  // ============================================================
  // BOX
  // ============================================================

  static Box<Guest> get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw Exception(
        'Guest Hive box is not initialized.',
      );
    }

    return Hive.box<Guest>(_boxName);
  }

  // ============================================================
  // GET GUESTS BY WEDDING
  // ============================================================

  static List<Guest> getGuestsByWedding(
    int weddingId,
  ) {
    return _box.values
        .where(
          (guest) => guest.weddingId == weddingId,
        )
        .toList();
  }

  // ============================================================
  // GET ALL GUESTS
  // ============================================================

  static List<Guest> getAllGuests() {
    return _box.values.toList();
  }

  // ============================================================
  // ADD GUEST
  // ============================================================

  static Future<void> addGuest(
    Guest guest,
  ) async {
    await _box.put(
      guest.localId,
      guest,
    );
  }

  // ============================================================
  // UPDATE GUEST
  // ============================================================

  static Future<void> updateGuest(
    Guest guest,
  ) async {
    await _box.put(
      guest.localId,
      guest,
    );
  }

  // ============================================================
  // DELETE GUEST
  // ============================================================

  static Future<void> deleteGuest(
    int localId,
  ) async {
    await _box.delete(localId);
  }

  // ============================================================
  // CLEAR ALL GUESTS
  // ============================================================

  static Future<void> clearAllGuests() async {
    await _box.clear();
  }
}