import 'package:flutter/material.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

import '../models/wedding.dart';
import '../services/api_service.dart';
import 'guest_list_screen.dart';
import 'money_taken_form.dart';
import 'balance_sheet_screen.dart';

class WeddingDetailScreen extends StatefulWidget {
  final Wedding wedding;
  const WeddingDetailScreen({super.key, required this.wedding});

  @override
  State<WeddingDetailScreen> createState() => _WeddingDetailScreenState();
}

class _WeddingDetailScreenState extends State<WeddingDetailScreen> {
  double guestTotal = 0;
  double takenTotal = 0;
  bool loading = true;

  Future<void> loadTotals() async {
    final guests = await ApiService.getGuests(widget.wedding.id);
    final taken = await ApiService.getTakenMoney(widget.wedding.id);

    setState(() {
      guestTotal = guests.fold(0.0, (t, g) => t + g.given);
      takenTotal = taken.fold(0.0, (t, m) => t + m.amount);
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTotals();
  }

  @override
  Widget build(BuildContext context) {
    final balance = guestTotal - takenTotal;

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // 🛕 Religious Header (devta always visible)
        appBar: _religiousHeader(),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [

                        _summary("कुल आया", guestTotal, Colors.green),
                        _summary("कुल गया", takenTotal, Colors.red),
                        _summary("शेष राशि", balance, Colors.blue),

                        const SizedBox(height: 28),

                        _bigButton("👥 मेहमान सूची", Colors.blue, () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  GuestListScreen(wedding: widget.wedding),
                            ),
                          );
                          loadTotals();
                        }),

                        _bigButton("💸 पैसा दिया गया", Colors.orange, () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MoneyTakenForm(wedding: widget.wedding),
                            ),
                          );
                          loadTotals();
                        }),

                        _bigButton("📊 बैलेंस शीट", Colors.purple, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BalanceSheetScreen(wedding: widget.wedding),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // =================== UI PARTS ===================

  PreferredSizeWidget _religiousHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(130),
      child: AppBar(
        backgroundColor: Colors.black.withOpacity(0.25),
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    Image.asset("assets/images/kalash.png", height: 42),
                    const Text("शुभ",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ]),
                  Column(children: [
                    Image.asset("assets/images/ganesh.png", height: 54),
                    const Text("🕉 श्री गणेशाय नमः",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ]),
                  Column(children: [
                    Image.asset("assets/images/lakshmi.png", height: 42),
                    const Text("लाभ",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ]),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellowAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${widget.wedding.groomNameHi} ❤️ ${widget.wedding.brideNameHi}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(String title, double amount, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("₹ ${amount.toStringAsFixed(0)}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _bigButton(String text, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
        ),
        onPressed: onTap,
        child: Text(text,
            style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      );
}
