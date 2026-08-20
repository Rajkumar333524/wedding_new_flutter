import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';

import '../models/wedding.dart';
import '../services/api_service.dart';

class ExportService {
  // ============================================================
  // DEVELOPER INFORMATION
  // ============================================================

  static const String developerName = 'Raj Kumar Pal';

  static const String collegeName =
      'Sam Higginbottom University of Agriculture, Technology and Sciences (SHUATS)';

  static const String developerAddress =
      'Prayagraj, Uttar Pradesh, India';

  // ============================================================
  // PDF EXPORT
  // ============================================================

  static Future<void> exportWeddingPdf(Wedding w) async {
    try {
      final pdf = pw.Document();

      final guests = await ApiService.getGuests(w.id);
      final taken = await ApiService.getTakenMoney(w.id);

      final totalGiven =
          guests.fold<double>(0, (sum, g) => sum + g.given);

      final totalGuestTaken =
          guests.fold<double>(0, (sum, g) => sum + g.taken);

      final totalOut =
          taken.fold<double>(0, (sum, t) => sum + t.amount);

      final balance = totalGiven - totalOut;

      // ----------------------------------------------------------
      // PDF PAGE
      // ----------------------------------------------------------

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(25),

          header: (context) {
            return pw.Column(
              children: [
                pw.Text(
                  'WEDDING REGISTER PRO',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 5),

                pw.Text(
                  'Wedding Register',
                  style: const pw.TextStyle(fontSize: 12),
                ),

                pw.Divider(),
              ],
            );
          },

          footer: (context) {
            return pw.Column(
              children: [
                pw.Divider(),

                pw.Text(
                  'Developed By: $developerName',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.Text(
                  collegeName,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 8),
                ),

                pw.Text(
                  developerAddress,
                  style: const pw.TextStyle(fontSize: 8),
                ),

                pw.SizedBox(height: 3),

                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            );
          },

          build: (context) => [
            // ====================================================
            // WEDDING DETAILS
            // ====================================================

            pw.Text(
              'WEDDING DETAILS',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.3),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _row('Bride Name', w.brideNameHi),
                _row('Groom Name', w.groomNameHi),
                _row('Location', w.location),
                _row('Date', w.date.toString()),
              ],
            ),

            pw.SizedBox(height: 15),

            // ====================================================
            // SUMMARY
            // ====================================================

            pw.Text(
              'ACCOUNT SUMMARY',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                _row('Total Given', '₹ ${_money(totalGiven)}'),
                _row(
                  'Guest Taken',
                  '₹ ${_money(totalGuestTaken)}',
                ),
                _row(
                  'Total Out',
                  '₹ ${_money(totalOut)}',
                ),
                _row(
                  'Balance',
                  '₹ ${_money(balance)}',
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ====================================================
            // GUEST REGISTER
            // ====================================================

            pw.Text(
              'GUEST REGISTER',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            guests.isEmpty
                ? pw.Text('No guest records found.')
                : pw.Table(
                    border: pw.TableBorder.all(),
                    defaultVerticalAlignment:
                        pw.TableCellVerticalAlignment.middle,

                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _header('S.No'),
                          _header('Name'),
                          _header('Address'),
                          _header('Gift'),
                          _header('Given'),
                          _header('Taken'),
                          _header('Type'),
                          _header('Date'),
                        ],
                      ),

                      ...List.generate(
                        guests.length,
                        (index) {
                          final g = guests[index];

                          return pw.TableRow(
                            children: [
                              _cell('${index + 1}'),

                              _cell(
                                _bilingual(
                                  g.nameEn,
                                  g.nameHi,
                                ),
                              ),

                              _cell(
                                _bilingual(
                                  g.addressEn,
                                  g.addressHi,
                                ),
                              ),

                              _cell(
                                _bilingual(
                                  g.giftEn,
                                  g.giftHi,
                                ),
                              ),

                              _cell(
                                '₹ ${_money(g.given)}',
                              ),

                              _cell(
                                '₹ ${_money(g.taken)}',
                              ),

                              _cell(g.type),

                              _cell(
                                _formatDate(g.date),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

            pw.SizedBox(height: 20),

            // ====================================================
            // TAKEN MONEY REGISTER
            // ====================================================

            pw.Text(
              'MONEY GIVEN / EXPENSE REGISTER',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            taken.isEmpty
                ? pw.Text('No money records found.')
                : pw.Table(
                    border: pw.TableBorder.all(),
                    defaultVerticalAlignment:
                        pw.TableCellVerticalAlignment.middle,

                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _header('S.No'),
                          _header('Person'),
                          _header('Amount'),
                        ],
                      ),

                      ...List.generate(
                        taken.length,
                        (index) {
                          final t = taken[index];

                          return pw.TableRow(
                            children: [
                              _cell('${index + 1}'),

                              _cell(
                                _bilingual(
                                  t.personNameEn,
                                  t.personNameHi,
                                ),
                              ),

                              _cell(
                                '₹ ${_money(t.amount)}',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
          ],
        ),
      );

      // ==========================================================
      // OPEN PRINT / SAVE PDF
      // ==========================================================

      await Printing.layoutPdf(
        name:
            'Wedding_Register_${w.id}.pdf',
        onLayout: (format) async {
          return pdf.save();
        },
      );
    } catch (e) {
      debugPrint(
        'PDF Export Error: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // EXCEL EXPORT - COMPLETE REGISTER
  // ============================================================

  static Future<void> exportWeddingsToExcel(
    List<Wedding> weddings,
  ) async {
    try {
      final excel = Excel.createExcel();

      // ----------------------------------------------------------
      // WEDDINGS SHEET
      // ----------------------------------------------------------

      final weddingSheet =
          excel['Weddings'];

      weddingSheet.appendRow([
        'S.No',
        'Bride Name',
        'Groom Name',
        'Location',
        'Date',
      ]);

      for (int i = 0; i < weddings.length; i++) {
        final w = weddings[i];

        weddingSheet.appendRow([
          i + 1,
          w.brideNameHi,
          w.groomNameHi,
          w.location,
          w.date,
        ]);
      }

      // ----------------------------------------------------------
      // COMPLETE GUEST REGISTER
      // ----------------------------------------------------------

      final guestSheet =
          excel['Guest Register'];

      guestSheet.appendRow([
        'Wedding',
        'S.No',
        'Name English',
        'Name Hindi',
        'Address English',
        'Address Hindi',
        'Gift English',
        'Gift Hindi',
        'Given',
        'Taken',
        'Type',
        'Date',
      ]);

      for (final w in weddings) {
        final guests =
            await ApiService.getGuests(w.id);

        for (int i = 0; i < guests.length; i++) {
          final g = guests[i];

          guestSheet.appendRow([
            '${w.groomNameHi} - ${w.brideNameHi}',
            i + 1,
            g.nameEn,
            g.nameHi,
            g.addressEn,
            g.addressHi,
            g.giftEn,
            g.giftHi,
            g.given,
            g.taken,
            g.type,
            g.date,
          ]);
        }
      }

      // ----------------------------------------------------------
      // MONEY REGISTER
      // ----------------------------------------------------------

      final moneySheet =
          excel['Money Register'];

      moneySheet.appendRow([
        'Wedding',
        'S.No',
        'Person English',
        'Person Hindi',
        'Amount',
      ]);

      for (final w in weddings) {
        final taken =
            await ApiService.getTakenMoney(w.id);

        for (int i = 0; i < taken.length; i++) {
          final t = taken[i];

          moneySheet.appendRow([
            '${w.groomNameHi} - ${w.brideNameHi}',
            i + 1,
            t.personNameEn,
            t.personNameHi,
            t.amount,
          ]);
        }
      }

      // ----------------------------------------------------------
      // SAVE EXCEL
      // ----------------------------------------------------------

      final dir =
          await getApplicationDocumentsDirectory();

      final file = File(
        '${dir.path}/Wedding_Register_Pro.xlsx',
      );

      final bytes = excel.encode();

      if (bytes == null) {
        throw Exception(
          'Excel file could not be generated.',
        );
      }

      await file.writeAsBytes(
        bytes,
        flush: true,
      );

      debugPrint(
        'Excel saved: ${file.path}',
      );
    } catch (e) {
      debugPrint(
        'Excel Export Error: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // PRINT WEDDING
  // ============================================================

  static Future<void> printWedding(
    Wedding w,
  ) async {
    await exportWeddingPdf(w);
  }

  // ============================================================
  // PDF TABLE HELPERS
  // ============================================================

  static pw.TableRow _row(
    String title,
    String value,
  ) {
    return pw.TableRow(
      children: [
        _header(title),
        _cell(value),
      ],
    );
  }

  static pw.Widget _header(
    String text,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _cell(
    String text,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 7,
        ),
      ),
    );
  }

  // ============================================================
  // BILINGUAL TEXT
  // ============================================================

  static String _bilingual(
    String english,
    String hindi,
  ) {
    final en = english.trim();
    final hi = hindi.trim();

    if (en.isEmpty && hi.isEmpty) {
      return '-';
    }

    if (en.isEmpty) {
      return hi;
    }

    if (hi.isEmpty) {
      return en;
    }

    return '$en\n$hi';
  }

  // ============================================================
  // MONEY
  // ============================================================

  static String _money(
    double value,
  ) {
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.00$'), '');
  }

  // ============================================================
  // DATE
  // ============================================================

  static String _formatDate(
    DateTime date,
  ) {
    final d =
        date.day.toString().padLeft(2, '0');

    final m =
        date.month.toString().padLeft(2, '0');

    return '$d-$m-${date.year}';
  }
}
