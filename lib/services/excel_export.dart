import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/guest.dart';

class ExcelExport {

  /// 📤 Export guests to Excel file
  static Future<File> exportGuests(List<Guest> guests, {String? fileName}) async {

    final excel = Excel.createExcel();
    final sheet = excel['Guest Register'];

    // 🧾 Header Row
    sheet.appendRow([
      'Name (EN)',
      'Name (HI)',
      'Address (EN)',
      'Address (HI)',
      'Given',
      'Taken',
      'Type',
      'Date'
    ]);

    // 🧾 Data Rows
    for (final g in guests) {
      sheet.appendRow([
        g.nameEn,
        g.nameHi,
        g.addressEn,
        g.addressHi,
        g.given,
        g.taken,
        g.type,
        g.date.toIso8601String(),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();

    final filePath =
        '${dir.path}/${fileName ?? "wedding_guest_register.xlsx"}';

    final file = File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    return file;
  }
}
