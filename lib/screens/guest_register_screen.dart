import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class GuestRegisterScreen extends StatefulWidget {
  final int weddingId;
  const GuestRegisterScreen({super.key, required this.weddingId});

  @override
  State<GuestRegisterScreen> createState() => _GuestRegisterScreenState();
}

class _GuestRegisterScreenState extends State<GuestRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final address = TextEditingController();
  final amount = TextEditingController();
  final gift = TextEditingController();

  // 🔑 Keyboard control
  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();

  bool saving = false;

  Future<void> saveGuest() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => saving = true);

      await ApiService.addGuest({
        "wedding": widget.weddingId,
        "name": name.text.trim(),
        "address": address.text.trim(),
        "amount": double.parse(amount.text.trim()),
        "gift": gift.text.trim(),
      });

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
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Save Failed: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.25),
          elevation: 0,
          title: const Text("Guest Entry"),
          centerTitle: true,
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
                      const Text("💐 Guest Registration 💐",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),

                      const SizedBox(height: 20),

                      _field("Guest Name", name, f1, f2, required: true),
                      _field("Address", address, f2, f3, required: true),
                      _field("Amount", amount, f3, f4,
                          required: true, number: true),
                      _field("Gift (Optional)", gift, f4, null),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: _goldButton(),
                          onPressed: saving ? null : saveGuest,
                          child: saving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.black, strokeWidth: 3))
                              : const Text("Save Guest",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16)),
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

  // ================== UI HELPERS ==================

  Widget _field(String label, TextEditingController c, FocusNode current,
      FocusNode? next,
      {bool required = false, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        focusNode: current,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        textInputAction: next == null ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (next != null) {
            FocusScope.of(context).requestFocus(next);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        validator:
            required ? (v) => v == null || v.isEmpty ? "Required" : null : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  ButtonStyle _goldButton() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 14,
        shadowColor: Colors.white70,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 15, offset: Offset(0, 8))
        ],
      );
}
