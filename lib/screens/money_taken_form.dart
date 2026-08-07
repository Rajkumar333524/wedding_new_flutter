import 'package:flutter/material.dart';

import '../models/wedding.dart';
import '../models/taken_money.dart';
import '../services/api_service.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class MoneyTakenForm extends StatefulWidget {
  final Wedding wedding;
  const MoneyTakenForm({super.key, required this.wedding});

  @override
  State<MoneyTakenForm> createState() => _MoneyTakenFormState();
}

class _MoneyTakenFormState extends State<MoneyTakenForm> {

  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _address = TextEditingController();

  // 🔑 Keyboard focus
  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();

  List<TakenMoney> takenList = [];
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadTaken();
  }

  Future<void> loadTaken() async {
    final data = await ApiService.getTakenMoney(widget.wedding.id);
    if (mounted) {
      setState(() {
        takenList = data;
        loading = false;
      });
    }
  }

  double get totalTaken =>
      takenList.fold(0, (t, m) => t + m.amount);

  Future<void> saveMoney() async {
    if (_name.text.isEmpty || _amount.text.isEmpty) {
      _msg("Name & Amount required");
      return;
    }

    setState(() => saving = true);

    try {
      final m = TakenMoney(
        id: DateTime.now().millisecondsSinceEpoch,
        weddingId: widget.wedding.id,
        personName: _name.text.trim(),
        amount: double.tryParse(_amount.text) ?? 0,
        address: _address.text.trim(),
      );

      await ApiService.addTakenMoney(m);

      _name.clear();
      _amount.clear();
      _address.clear();
      FocusScope.of(context).requestFocus(f1);

      await loadTaken();
      _msg("Saved successfully");
    } catch (e) {
      _msg("Error: $e");
    }

    if (mounted) setState(() => saving = false);
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
          title: const Text("💸 पैसा दिया गया"),
        ),

        body: Center(
          child: GlassPanel(
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [

                      /// 🧮 SUMMARY
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(14),
                        decoration: _card(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _stat("Records", takenList.length.toString(), Colors.blue),
                            _stat("Total ₹", totalTaken.toStringAsFixed(0), Colors.red),
                          ],
                        ),
                      ),

                      /// 📝 ENTRY FORM
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: _card(),
                        child: Column(
                          children: [
                            _field("नाम", _name, f1, f2),
                            _field("राशि", _amount, f2, f3, number: true),
                            _field("पता", _address, f3, null, last: true),

                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: _goldButton(),
                                onPressed: saving ? null : saveMoney,
                                child: saving
                                    ? const CircularProgressIndicator(color: Colors.black)
                                    : const Text("Save",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 📃 LIST
                      Expanded(
                        child: ListView.builder(
                          itemCount: takenList.length,
                          itemBuilder: (context, i) {
                            final m = takenList[i];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: _card(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.personName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),

                                  const SizedBox(height: 4),
                                  Text(m.address),

                                  const SizedBox(height: 6),
                                  Text("₹ ${m.amount}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red)),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _field(String t, TextEditingController c,
      FocusNode current, FocusNode? next,
      {bool number = false, bool last = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        focusNode: current,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (_) {
          if (next != null) {
            FocusScope.of(context).requestFocus(next);
          } else {
            saveMoney();
          }
        },
        decoration: InputDecoration(
          labelText: t,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _stat(String t, String v, Color c) => Column(children: [
        Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(v, style: TextStyle(fontSize: 18, color: c)),
      ]);

  ButtonStyle _goldButton() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        elevation: 14,
        shadowColor: Colors.black54,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 14),
        ],
      );
}
