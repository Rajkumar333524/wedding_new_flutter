import 'package:flutter/material.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';
import '../services/translator_service.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class AddWeddingScreen extends StatefulWidget {
  const AddWeddingScreen({super.key});

  @override
  State<AddWeddingScreen> createState() => _AddWeddingScreenState();
}

class _AddWeddingScreenState extends State<AddWeddingScreen> {
  final bride = TextEditingController();
  final groom = TextEditingController();
  final location = TextEditingController();

  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();

  DateTime? selectedDate;
  bool saving = false;

  Future<void> saveWedding() async {
    if (bride.text.isEmpty ||
        groom.text.isEmpty ||
        location.text.isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final brideHi = await TranslatorService.smartTranslate(bride.text);
      final groomHi = await TranslatorService.smartTranslate(groom.text);

      final wedding = Wedding(
        id: 0,
        brideNameEn: bride.text.trim(),
        groomNameEn: groom.text.trim(),
        brideNameHi: brideHi,
        groomNameHi: groomHi,
        location: location.text.trim(),
        date: selectedDate!.toIso8601String().split('T').first,
      );

      await ApiService.addWeddingObject(wedding);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("Wedding saved")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
      );
    }

    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("New Wedding"),
          backgroundColor: Colors.black.withOpacity(0.25),
          elevation: 0,
        ),
        body: Center(
          child: GlassPanel(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(24),
                decoration: _card(),
                child: Column(
                  children: [
                    const Text("Wedding Details",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _field("Bride Name", bride, f1, f2),
                    _field("Groom Name", groom, f2, f3),
                    _field("Location", location, f3, null, last: true),

                    const SizedBox(height: 12),
                    _datePicker(),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saving ? null : saveWedding,
                        style: _btnStyle(),
                        child: saving
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text("SAVE & CONTINUE",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _field(String label, TextEditingController c, FocusNode current,
      FocusNode? next,
      {bool last = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        focusNode: current,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (next != null) {
            FocusScope.of(context).requestFocus(next);
          } else {
            saveWedding();
          }
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _datePicker() => Row(
        children: [
          Expanded(
            child: Text(
              selectedDate == null
                  ? "Select Wedding Date"
                  : "Date: ${selectedDate!.toLocal().toString().split(' ')[0]}",
            ),
          ),
          ElevatedButton(
            style: _btnStyle(),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                initialDate: DateTime.now(),
              );
              if (d != null) setState(() => selectedDate = d);
            },
            child: const Text("Pick"),
          ),
        ],
      );

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        elevation: 18,
        shadowColor: Colors.amberAccent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
        ],
      );
}
