import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/translator_service.dart';
import '../models/guest.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class AddGuestForm extends StatefulWidget {
  final int weddingId;
  const AddGuestForm({super.key, required this.weddingId});

  @override
  State<AddGuestForm> createState() => _AddGuestFormState();
}

class _AddGuestFormState extends State<AddGuestForm> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _address = TextEditingController();
  final _gift = TextEditingController();
  final _amount = TextEditingController();

  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();

  bool loading = false;

  // ================= SAVE GUEST =================
  Future<void> saveGuest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final amount = double.tryParse(_amount.text.trim()) ?? 0;

      final nameHi = await TranslatorService.smartTranslate(_name.text);
      final addressHi = await TranslatorService.smartTranslate(_address.text);
      final giftHi = await TranslatorService.smartTranslate(_gift.text);

      final guest = Guest(
        id: 0,
        weddingId: widget.weddingId,
        nameEn: _name.text.trim(),
        nameHi: nameHi,
        addressEn: _address.text.trim(),
        addressHi: addressHi,
        giftEn: _gift.text.trim(),
        giftHi: giftHi,
        amount: amount,
      );

      await ApiService.addGuest(guest);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Guest Saved Successfully"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Save failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  // ================= FIELD BUILDER =================
  Widget _field(
    String label,
    TextEditingController c,
    FocusNode current,
    FocusNode? next, {
    bool required = false,
    bool number = false,
    bool last = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        focusNode: current,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (next != null) {
            FocusScope.of(context).requestFocus(next);
          } else {
            saveGuest(); // ENTER on last field = SAVE
          }
        },
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? "$label required" : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.85),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("शुभ विवाह • Guest Entry"),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("💐 अतिथि विवरण 💐",
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text("Guest Registration • मेहमान जानकारी"),
                      const Divider(height: 30),

                      _field("Name / नाम", _name, f1, f2, required: true),
                      _field("Address / पता", _address, f2, f3),
                      _field("Gift / उपहार", _gift, f3, f4),
                      _field("Amount / राशि", _amount, f4, null,
                          required: true, number: true, last: true),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: _btnStyle(),
                          onPressed: loading ? null : saveGuest,
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.black)
                              : const Text("SAVE GUEST",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
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

  // ================= STYLES =================
  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37), // GOLD
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 18,
        shadowColor: Colors.amberAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        hinting: true,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
        ],
      );
}
