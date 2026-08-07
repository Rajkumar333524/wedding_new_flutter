import 'package:flutter/material.dart';
import '../models/guest.dart';
import '../services/hive_service.dart';
import '../services/offline_service.dart';
import '../services/api_service.dart';

class GuestProvider extends ChangeNotifier {

  bool _initialized = false;

  // 🚀 App start pe ek hi baar load
  Future<void> initialize() async {
    if (_initialized) return;

    final offlineGuests = OfflineService.loadGuests();
    for (var g in offlineGuests) {
      HiveService.addOrUpdateGuest(g);
    }

    _initialized = true;
    notifyListeners();
  }

  // 📥 Load all guests of wedding
  List<Guest> loadGuests(int weddingId) {
    return HiveService.getGuestsByWedding(weddingId);
  }

  // ➕ Add Guest (Online + Offline + Local cache)
  Future<void> addGuest(Guest guest) async {
    HiveService.addOrUpdateGuest(guest);
    OfflineService.saveGuest(guest);

    try {
      await ApiService.addGuest(guest);
    } catch (_) {}

    notifyListeners();
  }

  // ✏ Update Guest
  Future<void> updateGuest(Guest guest) async {
    HiveService.addOrUpdateGuest(guest);
    OfflineService.saveGuest(guest);

    try {
      await ApiService.updateGuest(guest);
    } catch (_) {}

    notifyListeners();
  }

  // 🗑 Delete Guest
  Future<void> deleteGuest(int guestId) async {
    HiveService.deleteGuestById(guestId);
    OfflineService.deleteGuest(guestId);

    try {
      await ApiService.deleteGuest(guestId);
    } catch (_) {}

    notifyListeners();
  }

  // 📊 Calculations
  double totalGiven(int weddingId) => HiveService.getTotalGiven(weddingId);
  double totalTaken(int weddingId) => HiveService.getTotalTaken(weddingId);
  int totalGuests(int weddingId) => HiveService.getTotalGuests(weddingId);
  double balance(int weddingId) => HiveService.getBalance(weddingId);
}
