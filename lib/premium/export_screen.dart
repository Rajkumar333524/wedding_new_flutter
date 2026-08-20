import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../cloud/cloud_screen.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

import '../services/export_service.dart';
import '../services/api_service.dart';

import '../models/wedding.dart';

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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BACKUP
  // ============================================================

  Future<void> backupNow() async {
    setState(() {
      working = true;
      status = "Creating Backup...";
    });

    try {
      final file = await OfflineService.createBackup();

      show(
        "Backup saved successfully\n${file.path}",
      );
    } catch (e) {
      show("Backup error: $e");
    } finally {
      if (mounted) {
        setState(() {
          working = false;
          status = "";
        });
      }
    }
  }

  // ============================================================
  // RESTORE
  // ============================================================

  Future<void> restoreNow() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null ||
        result.files.single.path == null) {
      return;
    }

    final file = File(
      result.files.single.path!,
    );

    setState(() {
      working = true;
      status = "Restoring Backup...";
    });

    try {
      await OfflineService.restoreBackup(file);

      show(
        "Backup restored successfully",
      );
    } catch (e) {
      show("Restore error: $e");
    } finally {
      if (mounted) {
        setState(() {
          working = false;
          status = "";
        });
      }
    }
  }

  // ============================================================
  // GET WEDDINGS
  // ============================================================

  Future<List<Wedding>> _loadWeddings() async {
    return ApiService.getWeddings();
  }

  // ============================================================
  // PDF EXPORT
  // ============================================================

  Future<void> exportPdf() async {
    setState(() {
      working = true;
      status = "Loading Weddings...";
    });

    try {
      final weddings = await _loadWeddings();

      if (weddings.isEmpty) {
        show("No wedding record found.");
        return;
      }

      if (!mounted) return;

      final selected = await showDialog<Wedding>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              "Select Wedding",
            ),
            content: SizedBox(
              width: 500,
              height: 350,
              child: ListView.builder(
                itemCount: weddings.length,
                itemBuilder: (_, index) {
                  final w = weddings[index];

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.favorite),
                      ),
                      title: Text(
                        "${w.groomNameHi} ❤️ ${w.brideNameHi}",
                      ),
                      subtitle: Text(
                        "${w.location}\n${w.date}",
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.pop(
                          dialogContext,
                          w,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );

      if (selected == null) {
        return;
      }

      setState(() {
        working = true;
        status = "Generating Complete PDF...";
      });

      await ExportService.exportWeddingPdf(
        selected,
      );

      show(
        "Complete Wedding PDF opened successfully.",
      );
    } catch (e) {
      show(
        "PDF Export error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          working = false;
          status = "";
        });
      }
    }
  }

  // ============================================================
  // EXCEL EXPORT
  // ============================================================

  Future<void> exportExcel() async {
    setState(() {
      working = true;
      status = "Creating Complete Excel Register...";
    });

    try {
      final weddings = await _loadWeddings();

      if (weddings.isEmpty) {
        show("No wedding record found.");
        return;
      }

      await ExportService.exportWeddingsToExcel(
        weddings,
      );

      show(
        "Complete Excel Register created successfully.",
      );
    } catch (e) {
      show(
        "Excel Export error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          working = false;
          status = "";
        });
      }
    }
  }

  // ============================================================
  // PRINT
  // ============================================================

  Future<void> printWedding() async {
    setState(() {
      working = true;
      status = "Loading Wedding...";
    });

    try {
      final weddings = await _loadWeddings();

      if (weddings.isEmpty) {
        show("No wedding record found.");
        return;
      }

      if (!mounted) return;

      final selected = await showDialog<Wedding>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              "Select Wedding to Print",
            ),
            content: SizedBox(
              width: 500,
              height: 350,
              child: ListView.builder(
                itemCount: weddings.length,
                itemBuilder: (_, index) {
                  final w = weddings[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.print,
                        color: Colors.blue,
                      ),
                      title: Text(
                        "${w.groomNameHi} ❤️ ${w.brideNameHi}",
                      ),
                      subtitle: Text(
                        w.location,
                      ),
                      onTap: () {
                        Navigator.pop(
                          dialogContext,
                          w,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );

      if (selected == null) {
        return;
      }

      setState(() {
        working = true;
        status = "Opening Print Preview...";
      });

      await ExportService.printWedding(
        selected,
      );

      show(
        "Print preview opened.",
      );
    } catch (e) {
      show(
        "Print error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          working = false;
          status = "";
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          "Premium Export & Backup",
        ),
        backgroundColor:
            const Color(0xff4A6CF7),
      ),

      body: BackgroundWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: GlassPanel(
              child: SizedBox(
                width: 600,

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    const Text(
                      "📦 Data Management",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      "Wedding Register Pro",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    if (working)
                      Container(
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),
                        margin:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          color: Colors.white
                              .withOpacity(
                            0.75,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                status,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // BACKUP
                    _btn(
                      "Create Backup",
                      Icons.save,
                      Colors.orange,
                      backupNow,
                    ),

                    // RESTORE
                    _btn(
                      "Restore Backup",
                      Icons.restore,
                      Colors.purple,
                      restoreNow,
                    ),

                    // CLOUD
                    _btn(
                      "Cloud Backup",
                      Icons.cloud,
                      Colors.indigo,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CloudScreen(),
                          ),
                        );
                      },
                    ),

                    // PDF
                    _btn(
                      "Export Complete PDF",
                      Icons.picture_as_pdf,
                      Colors.red,
                      exportPdf,
                    ),

                    // PRINT
                    _btn(
                      "Print Wedding Register",
                      Icons.print,
                      Colors.blue,
                      printWedding,
                    ),

                    // EXCEL
                    _btn(
                      "Export Complete Excel",
                      Icons.table_chart,
                      Colors.green,
                      exportExcel,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "PDF / Excel includes Wedding + Guest Register + Money Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUTTON
  // ============================================================

  Widget _btn(
    String text,
    IconData icon,
    Color color,
    VoidCallback action,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      width: double.infinity,

      child: ElevatedButton.icon(
        onPressed:
            working ? null : action,

        icon: Icon(icon),

        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        style:
            ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,

          padding:
              const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 18,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),

          elevation: 5,
        ),
      ),
    );
  }
}
