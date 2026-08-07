import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';

class ExportService {

  // ===================== PDF EXPORT =====================
  static Future<void> exportWeddingPdf(Wedding w) async {
    try {
      final pdf = pw.Document();

      final guests = await ApiService.getGuests(w.id);
      final taken = await ApiService.getTakenMoney(w.id);

      final totalIn = guests.fold<double>(0, (t, g) => t + g.given);
      final totalOut = taken.fold<double>(0, (t, m) => t + m.amount);
      final balance = totalIn - totalOut;

      pdf.addPage(
        pw.Page(
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text("🕉 श्री गणेशाय नमः", style: pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 4),
              pw.Text("शुभ विवाह", style: pw.TextStyle(fontSize: 18)),
              pw.Text("${w.groomNameHi} ❤️ ${w.brideNameHi}"),
              pw.SizedBox(height: 12),

              pw.Text("कुल प्राप्त : ₹ $totalIn"),
              pw.Text("कुल दिया : ₹ $totalOut"),
              pw.Text("शेष राशि : ₹ $balance"),

              pw.SizedBox(height: 16),

              pw.Text("मेहमान सूची:", style: pw.TextStyle(fontSize: 16)),
              pw.Divider(),
              ...guests.map((g) => pw.Text("${g.nameHi}   ₹${g.given}")),

              pw.SizedBox(height: 12),

              pw.Text("पैसा दिया गया:", style: pw.TextStyle(fontSize: 16)),
              pw.Divider(),
              ...taken.map((t) => pw.Text("${t.personNameHi}   ₹${t.amount}")),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (_) => pdf.save());
    } catch (e) {
      debugPrint("PDF Export Error: $e");
    }
  }

  // ===================== EXCEL EXPORT =====================
  static Future<void> exportWeddingsToExcel(List<Wedding> weddings) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Weddings'];

      sheet.appendRow(["Bride", "Groom", "Location", "Date"]);

      for (final w in weddings) {
        sheet.appendRow([
          w.brideNameHi,
          w.groomNameHi,
          w.location,
          w.date,
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/weddings.xlsx");

      await file.writeAsBytes(excel.encode()!);
    } catch (e) {
      debugPrint("Excel Export Error: $e");
    }
  }

  // ===================== PRINT =====================
  static Future<void> printWedding(Wedding w) async {
    await exportWeddingPdf(w);
  }
}
