import 'package:hive/hive.dart';
import '../models/guest.dart';

class HiveService {
  static const String _boxName = "guestBox";
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized && Hive.isBoxOpen(_boxName)) return;

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GuestAdapter());
    }

    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Guest>(_boxName);
    }

    _initialized = true;
  }

  static Box<Guest> get _box => Hive.box<Guest>(_boxName);

  static List<Guest> getGuestsByWedding(int weddingId) {
    return _box.values.where((g) => g.weddingId == weddingId).toList();
  }

  static Future<void> addGuest(Guest guest) async {
    await _box.put(guest.id, guest);
  }

  static Future<void> updateGuest(Guest guest) async {
    await _box.put(guest.id, guest);
  }

  static Future<void> deleteGuest(int id) async {
    await _box.delete(id);
  }
}
