import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/wedding.dart';
import '../models/guest.dart';
import '../models/taken_money.dart';
import '../services/api_service.dart';

class OfflineService {

  /// 📦 Create full backup file
  static Future<File> createBackup() async {
    final weddings = await ApiService.getWeddings();

    final Map<String, dynamic> data = {
      "weddings": [],
      "guests": [],
      "taken": [],
      "created": DateTime.now().toIso8601String(),
    };

    for (final w in weddings) {
      data["weddings"].add(w.toJson());

      final guests = await ApiService.getGuests(w.id);
      final taken = await ApiService.getTakenMoney(w.id);

      for (final g in guests) {
        data["guests"].add(g.toJson());
      }

      for (final t in taken) {
        data["taken"].add(t.toJson());
      }
    }

    final jsonStr = jsonEncode(data);

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/wedding_backup.json");

    return file.writeAsString(jsonStr);
  }

  /// 🔄 Restore from backup file
  static Future<void> restoreBackup(File file) async {
    final text = await file.readAsString();
    final data = jsonDecode(text);

    for (final w in data["weddings"]) {
      await ApiService.addWeddingObject(Wedding.fromJson(w));
    }

    for (final g in data["guests"]) {
      await ApiService.addGuest(Guest.fromJson(g));
    }

    for (final t in data["taken"]) {
      await ApiService.addTakenMoney(TakenMoney.fromJson(t));
    }
  }
}
