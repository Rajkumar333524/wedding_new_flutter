import 'package:flutter/material.dart';

import '../premium/export_screen.dart';
import '../rituals/ritual_home_screen.dart';

import '../models/wedding.dart';
import '../models/guest.dart';
import '../models/taken_money.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class BalanceSheetScreen extends StatefulWidget {
  final Wedding wedding;
  const BalanceSheetScreen({super.key, required this.wedding});

  @override
  State<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends State<BalanceSheetScreen> {
  List<Guest> guests = [];
  List<TakenMoney> taken = [];

  double totalReceived = 0;
  double totalGiven = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final g = await ApiService.getGuests(widget.wedding.id);
      final t = await ApiService.getTakenMoney(widget.wedding.id);

      if (!mounted) return;

      setState(() {
        guests = g;
        taken = t;

        totalReceived = guests.fold(0, (x, e) => x + e.given);
        totalGiven    = taken.fold(0, (x, e) => x + e.amount);

        loading = false;
      });
    } catch (e) {
      debugPrint("Balance load error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = totalReceived - totalGiven;

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.25),
          elevation: 0,
          title: const Text("📊 Balance Sheet"),
        ),

        body: Center(
          child: GlassPanel(
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        _summaryCard("कुल प्राप्त", totalReceived, Colors.green),
                        _summaryCard("कुल दिया", totalGiven, Colors.red),
                        _summaryCard("शेष राशि", balance, Colors.blue),

                        const SizedBox(height: 20),

                        _sectionTitle("👥 मेहमान सूची"),
                        _guestTable(),

                        const SizedBox(height: 20),

                        _sectionTitle("💸 पैसा दिया गया"),
                        _takenTable(),

                        const SizedBox(height: 26),

                        // ===== PREMIUM BUTTON BAR =====

                        Row(
                          children: [

                            _goldButton("Export", Icons.workspace_premium, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ExportScreen()),
                              );
                            }),

                            const SizedBox(width: 10),

                            _silverButton("PDF", Icons.picture_as_pdf, () {
                              ExportService.exportPDF(widget.wedding);
                            }),

                            const SizedBox(width: 10),

                            _silverButton("Excel", Icons.table_chart, () {
                              ExportService.exportExcel(widget.wedding);
                            }),

                            const SizedBox(width: 10),

                            _silverButton("Print", Icons.print, () {
                              ExportService.printLedger(widget.wedding);
                            }),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ===== RITUAL LINK BUTTON =====

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text("Ritual & Rasham Dashboard"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              elevation: 20,
                              shadowColor: Colors.amberAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RitualHomeScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _summaryCard(String title, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("₹ ${value.toStringAsFixed(0)}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _guestTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text("नाम")),
        DataColumn(label: Text("पता")),
        DataColumn(label: Text("दिया")),
      ],
      rows: guests.map((g) {
        return DataRow(cells: [
          DataCell(Text(g.nameHi)),
          DataCell(Text(g.addressHi)),
          DataCell(Text("₹ ${g.given}")),
        ]);
      }).toList(),
    );
  }

  Widget _takenTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text("नाम")),
        DataColumn(label: Text("पता")),
        DataColumn(label: Text("राशि")),
      ],
      rows: taken.map((t) {
        return DataRow(cells: [
          DataCell(Text(t.personNameHi)),
          DataCell(Text(t.addressHi)),
          DataCell(Text("₹ ${t.amount}")),
        ]);
      }).toList(),
    );
  }

  Widget _goldButton(String text, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          elevation: 18,
          shadowColor: Colors.amberAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _silverButton(String text, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBDC3C7),
          foregroundColor: Colors.black,
          elevation: 14,
          shadowColor: Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 8)),
        ],
      );
}
