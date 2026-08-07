import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/guest_provider.dart';
import '../models/guest.dart';
import '../services/language_service.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';
import 'page3_guest_register.dart';

class Page2GuestEntry extends StatefulWidget {
  final int weddingId;
  const Page2GuestEntry({super.key, required this.weddingId});

  @override
  State<Page2GuestEntry> createState() => _Page2GuestEntryState();
}

class _Page2GuestEntryState extends State<Page2GuestEntry> {

  final nameEn = TextEditingController();
  final nameHi = TextEditingController();
  final addressEn = TextEditingController();
  final addressHi = TextEditingController();
  final giftEn = TextEditingController();
  final giftHi = TextEditingController();
  final given = TextEditingController();
  final taken = TextEditingController();

  // 🔑 Keyboard focus chain
  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();
  final f5 = FocusNode();
  final f6 = FocusNode();
  final f7 = FocusNode();
  final f8 = FocusNode();

  String type = "Given";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      FocusScope.of(context).requestFocus(f1);
    });
  }

  void saveGuest() {
    if (nameEn.text.isEmpty && nameHi.text.isEmpty) return;

    final provider = context.read<GuestProvider>();

    final guest = Guest(
      id: DateTime.now().millisecondsSinceEpoch,
      weddingId: widget.weddingId,
      nameEn: nameEn.text.trim(),
      nameHi: nameHi.text.trim(),
      addressEn: addressEn.text.trim(),
      addressHi: addressHi.text.trim(),
      giftEn: giftEn.text.trim(),
      giftHi: giftHi.text.trim(),
      given: double.tryParse(given.text) ?? 0,
      taken: double.tryParse(taken.text) ?? 0,
      type: type,
      date: DateTime.now(),
    );

    provider.addGuest(guest);

    nameEn.clear();
    nameHi.clear();
    addressEn.clear();
    addressHi.clear();
    giftEn.clear();
    giftHi.clear();
    given.clear();
    taken.clear();

    FocusScope.of(context).requestFocus(f1);
  }

  Widget field(String hint, TextEditingController ctrl, FocusNode cur, FocusNode? next) {
    return TextField(
      controller: ctrl,
      focusNode: cur,
      textInputAction: next == null ? TextInputAction.done : TextInputAction.next,
      onSubmitted: (_) {
        if (next != null) {
          FocusScope.of(context).requestFocus(next);
        } else {
          saveGuest();
        }
      },
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService;

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: Text(lang.text("Guest Entry", "अतिथि विवरण")),
          backgroundColor: Colors.black.withOpacity(0.25),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.translate),
              onPressed: () => setState(() => lang.toggleLanguage()),
            )
          ],
        ),

        body: Center(
          child: GlassPanel(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [

                Row(children: [
                  Expanded(child: field(lang.text("Name (English)", "नाम (अंग्रेज़ी)"), nameEn, f1, f2)),
                  const SizedBox(width: 10),
                  Expanded(child: field(lang.text("Name (Hindi)", "नाम (हिंदी)"), nameHi, f2, f3)),
                ]),

                const SizedBox(height: 10),

                Row(children: [
                  Expanded(child: field(lang.text("Address (English)", "पता (अंग्रेज़ी)"), addressEn, f3, f4)),
                  const SizedBox(width: 10),
                  Expanded(child: field(lang.text("Address (Hindi)", "पता (हिंदी)"), addressHi, f4, f5)),
                ]),

                const SizedBox(height: 10),

                Row(children: [
                  Expanded(child: field(lang.text("Gift (English)", "उपहार (अंग्रेज़ी)"), giftEn, f5, f6)),
                  const SizedBox(width: 10),
                  Expanded(child: field(lang.text("Gift (Hindi)", "उपहार (हिंदी)"), giftHi, f6, f7)),
                ]),

                const SizedBox(height: 10),

                Row(children: [
                  Expanded(child: field(lang.text("Given Amount", "दिया गया"), given, f7, f8)),
                  const SizedBox(width: 10),
                  Expanded(child: field(lang.text("Taken Amount", "लिया गया"), taken, f8, null)),
                ]),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Given", child: Text("Given")),
                    DropdownMenuItem(value: "Taken", child: Text("Taken")),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                ),

                const SizedBox(height: 18),

                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveGuest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        elevation: 12,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(lang.text("Save Entry", "सेव करें")),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Page3GuestRegister()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBDC3C7),
                        foregroundColor: Colors.black,
                        elevation: 10,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(lang.text("View Register", "रजिस्टर देखें")),
                    ),
                  ),
                ])
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
