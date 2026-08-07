import '../premium/offline_service.dart';

class CloudBackupService {

  static Future<void> uploadBackup() async {
    throw Exception(
      "Cloud backup is disabled in Web build. Enable only on Android/iOS."
    );
  }

  static Future<void> restoreFromCloud() async {
    throw Exception(
      "Cloud restore is disabled in Web build. Enable only on Android/iOS."
    );
  }
}
