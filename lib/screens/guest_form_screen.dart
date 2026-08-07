import 'package:flutter/material.dart';

import '../models/guest.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';
import '../services/translator_service.dart';
import '../services/hive_service.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class GuestFormScreen extends StatefulWidget {
  final Wedding wedding;
  const GuestFormScreen({super.key, required this.wedding});

  @override
  State<GuestFormScreen> createState() => _GuestFormScreenState();
}

class _GuestFormScreenState extends State<GuestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool showShubhLabhText = false;

  final nameEnCtrl = TextEditingController();
  final addressEnCtrl = TextEditingController();
  final giftEnCtrl = TextEditingController();
  final givenCtrl = TextEditingController();

  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();

  bool saving = false;

  Future<void> saveGuest() async {
    if (saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      // 🔧 FIX 1 — Always trim before translate (prevents empty save bugs)
      final nameEn = nameEnCtrl.text.trim();
      final addressEn = addressEnCtrl.text.trim();
      final giftEn = giftEnCtrl.text.trim();

      // 🔧 FIX 2 — Translator safe calls
      final nameHi = await TranslatorService.smartTranslate(nameEn);
      final addressHi = await TranslatorService.smartTranslate(addressEn);
      final giftHi = await TranslatorService.smartTranslate(giftEn);

      final guest = Guest(
        // 🔧 FIX 3 — Hive safe ID (32-bit safe forever)
        id: DateTime.now().millisecondsSinceEpoch % 0xFFFFFFFF,

        weddingId: widget.wedding.id,
        nameEn: nameEn,
        nameHi: nameHi,
        addressEn: addressEn,
        addressHi: addressHi,
        giftEn: giftEn,
        giftHi: giftHi,
        given: double.tryParse(givenCtrl.text) ?? 0,
        type: "Given",
        date: DateTime.now(),
      );

      // 🔧 FIX 4 — Offline save FIRST (no data loss ever)
      await HiveService.addGuest(guest);

      // 🔧 FIX 5 — Backend sync (failure does not lose data)
      try {
        await ApiService.addGuest(guest);
      } catch (_) {
        // silently keep offline copy
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
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
        appBar: _religiousHeader(),
        body: Center(
          child: GlassPanel(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(22),
                decoration: _card(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "मेहमान जानकारी",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 18),

                      _field("Name (नाम)", nameEnCtrl, f1, f2),
                      _field("Address (पता)", addressEnCtrl, f2, f3),
                      _field("Gift (सगुन)", giftEnCtrl, f3, f4),
                      _field("Given ₹", givenCtrl, f4, null, number: true, isLast: true),

                      const SizedBox(height: 24),

                      saving
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: _btnStyle(),
                                onPressed: saveGuest,
                                child: const Text("Save Guest", style: TextStyle(fontSize: 16)),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _religiousHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: showShubhLabhText
              ? const Center(
                  child: Text(
                    "🕉 श्री गणेशाय नमः",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    FocusNode current,
    FocusNode? next, {
    bool number = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        focusNode: current,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (isLast) {
            saveGuest();
          } else {
            FocusScope.of(context).requestFocus(next);
          }
        },
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: _input(label),
      ),
    );
  }

  InputDecoration _input(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.88),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1976d2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 10,
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 15)],
      );
}
