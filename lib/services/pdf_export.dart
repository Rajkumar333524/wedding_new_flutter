import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/guest.dart';

class PdfExport {

  /// 📤 Generate & preview printable PDF
  static Future<void> exportGuests(List<Guest> guests,
      {String title = "Wedding Guest Register"}) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(title,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              )),
          pw.SizedBox(height: 12),

          pw.Table.fromTextArray(
            headers: [
              'Name EN',
              'Name HI',
              'Address EN',
              'Address HI',
              'Given',
              'Taken',
              'Type',
              'Date'
            ],
            data: guests.map((g) => [
              g.nameEn,
              g.nameHi,
              g.addressEn,
              g.addressHi,
              g.given.toString(),
              g.taken.toString(),
              g.type,
              g.date.toIso8601String(),
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// 🧾 Generate raw PDF file bytes (for save / share)
  static Future<Uint8List> generateBytes(List<Guest> guests) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          children: guests.map((g) =>
            pw.Text('${g.nameEn}   ₹${g.given}   ₹${g.taken}')).toList(),
        ),
      ),
    );

    return pdf.save();
  }
}
