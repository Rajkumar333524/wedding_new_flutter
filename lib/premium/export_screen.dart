import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../cloud/cloud_screen.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

import '../services/export_service.dart';
import '../services/api_service.dart';
import 'offline_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {

  bool working = false;
  String status = "";

  void show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> backupNow() async {
    setState(() {
      working = true;
      status = "Creating Backup...";
    });

    try {
      final file = await OfflineService.createBackup();
      show("Backup saved: ${file.path}");
    } catch (e) {
      show("Backup error: $e");
    }

    setState(() => working = false);
  }

  Future<void> restoreNow() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      working = true;
      status = "Restoring Backup...";
    });

    try {
      await OfflineService.restoreBackup(file);
      show("Backup restored successfully");
    } catch (e) {
      show("Restore error: $e");
    }

    setState(() => working = false);
  }

  Future<void> exportPdf() async {
    setState(() {
      working = true;
      status = "Exporting PDF...";
    });

    try {
      final weddings = await ApiService.getWeddings();
      for (final w in weddings) {
        await ExportService.exportWeddingPdf(w);
      }
      show("PDF Export Completed");
    } catch (e) {
      show("PDF Export error: $e");
    }

    setState(() => working = false);
  }

  Future<void> exportExcel() async {
    setState(() {
      working = true;
      status = "Exporting Excel...";
    });

    try {
      final weddings = await ApiService.getWeddings();
      await ExportService.exportWeddingsToExcel(weddings);
      show("Excel Export Completed");
    } catch (e) {
      show("Excel Export error: $e");
    }

    setState(() => working = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text("Premium Export & Backup"),
        backgroundColor: const Color(0xff4A6CF7),
      ),

      body: BackgroundWrapper(
        child: Center(
          child: GlassPanel(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text("📦 Data Management",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 16),

                  if (working)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(status),
                      ],
                    ),

                  const SizedBox(height: 20),

                  _btn("Create Backup", Icons.save, Colors.orange, backupNow),
                  _btn("Restore Backup", Icons.restore, Colors.purple, restoreNow),

                  _btn("Cloud Backup", Icons.cloud, Colors.indigo, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CloudScreen()),
                    );
                  }),

                  _btn("Export PDF", Icons.picture_as_pdf, Colors.red, exportPdf),
                  _btn("Export Excel", Icons.table_chart, Colors.green, exportExcel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(String t, IconData i, Color c, VoidCallback f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(i),
        label: Text(t),
        onPressed: working ? null : f,
        style: ElevatedButton.styleFrom(
          backgroundColor: c,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
