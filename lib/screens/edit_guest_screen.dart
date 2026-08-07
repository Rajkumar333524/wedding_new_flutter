import 'package:flutter/material.dart';

import '../models/guest.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../services/translator_service.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class EditGuestScreen extends StatefulWidget {
  final Guest guest;

  const EditGuestScreen({super.key, required this.guest});

  @override
  State<EditGuestScreen> createState() => _EditGuestScreenState();
}

class _EditGuestScreenState extends State<EditGuestScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameEn;
  late final TextEditingController addressEn;
  late final TextEditingController giftEn;
  late final TextEditingController given;

  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameEn = TextEditingController(text: widget.guest.nameEn);
    addressEn = TextEditingController(text: widget.guest.addressEn);
    giftEn = TextEditingController(text: widget.guest.giftEn);
    given = TextEditingController(text: widget.guest.given.toString());
  }

  Future<void> updateGuest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      // 🔁 ALWAYS translate fresh
      final nameHi = await TranslatorService.smartTranslate(nameEn.text.trim());
      final addressHi = await TranslatorService.smartTranslate(addressEn.text.trim());
      final giftHi = await TranslatorService.smartTranslate(giftEn.text.trim());

      final updated = Guest(
        id: widget.guest.id,
        weddingId: widget.guest.weddingId,
        nameEn: nameEn.text.trim(),
        nameHi: nameHi,
        addressEn: addressEn.text.trim(),
        addressHi: addressHi,
        giftEn: giftEn.text.trim(),
        giftHi: giftHi,
        given: double.tryParse(given.text) ?? 0,
        type: widget.guest.type,
        date: widget.guest.date,
      );

      // 🧱 LOCAL overwrite (data kabhi gayab nahi hoga)
      await HiveService.updateGuest(updated);

      // 🌐 BACKEND overwrite
      await ApiService.updateGuest(updated);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Update failed: $e")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Edit Guest"),
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
                      const Text("✏️ Update Guest",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      _field("Name", nameEn, f1, f2),
                      _field("Address", addressEn, f2, f3),
                      _field("Gift", giftEn, f3, f4),
                      _field("Given Amount", given, f4, null, number: true, last: true),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _goldButton(
                              loading ? "Saving..." : "Update",
                              Icons.save,
                              loading ? null : updateGuest,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _silverButton("Cancel", Icons.close, () {
                              Navigator.pop(context);
                            }),
                          ),
                        ],
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

  Widget _field(String label, TextEditingController c, FocusNode current,
      FocusNode? next,
      {bool number = false, bool last = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        focusNode: current,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (last) updateGuest();
          else FocusScope.of(context).requestFocus(next);
        },
        validator: (v) => v == null || v.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _goldButton(String text, IconData icon, VoidCallback? onTap) {
    return ElevatedButton.icon(
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
    );
  }

  Widget _silverButton(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
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
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
        ],
      );
}
