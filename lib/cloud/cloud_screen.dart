import 'package:flutter/material.dart';
import 'cloud_backup_service.dart';

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key});

  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  bool working = false;
  String status = "";

  void show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> upload() async {
    setState(() { working = true; status = "Uploading..."; });
    await CloudBackupService.uploadBackup();
    show("Backup uploaded to Google Drive");
    setState(() => working = false);
  }

  Future<void> restore() async {
    setState(() { working = true; status = "Restoring..."; });
    await CloudBackupService.restoreFromCloud();
    show("Backup restored from cloud");
    setState(() => working = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloud Backup")),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (working) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(status),
          ],
          const SizedBox(height: 24),
          ElevatedButton(onPressed: upload, child: const Text("Upload to Drive")),
          ElevatedButton(onPressed: restore, child: const Text("Restore from Drive")),
        ]),
      ),
    );
  }
}
