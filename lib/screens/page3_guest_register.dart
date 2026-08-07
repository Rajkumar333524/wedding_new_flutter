import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/guest_provider.dart';
import '../services/language_service.dart';
import '../services/pdf_export.dart';
import '../services/excel_export.dart';
import '../models/guest.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class Page3GuestRegister extends StatefulWidget {
  final int weddingId;
  const Page3GuestRegister({super.key, required this.weddingId});

  @override
  State<Page3GuestRegister> createState() => _Page3GuestRegisterState();
}

class _Page3GuestRegisterState extends State<Page3GuestRegister> {
  final searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuestProvider>();
    final lang = LanguageService;

    final guests = provider.loadGuests(widget.weddingId);

    final filtered = guests.where((g) {
      final q = searchCtrl.text.toLowerCase();
      return g.nameEn.toLowerCase().contains(q) ||
          g.nameHi.toLowerCase().contains(q) ||
          g.addressEn.toLowerCase().contains(q) ||
          g.addressHi.toLowerCase().contains(q);
    }).toList();

    final totalGuests = filtered.length;
    final totalGiven = filtered.fold(0.0, (t, g) => t + g.given);
    final totalTaken = filtered.fold(0.0, (t, g) => t + g.taken);
    final balance = totalGiven - totalTaken;

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.25),
          elevation: 0,
          title: Text(lang.text("Guest Register", "अतिथि रजिस्टर")),
          actions: [
            IconButton(
              icon: const Icon(Icons.translate),
              onPressed: () => setState(() => lang.toggleLanguage()),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {}),
            ),
          ],
        ),

        body: Center(
          child: GlassPanel(
            child: Column(
              children: [

                // 🧮 SUMMARY
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      summaryCard(lang.text("Guests","मेहमान"), "$totalGuests", Colors.teal),
                      summaryCard(lang.text("Given","दिया"), "₹$totalGiven", Colors.blue),
                      summaryCard(lang.text("Taken","लिया"), "₹$totalTaken", Colors.orange),
                      summaryCard(lang.text("Balance","बाकी"), "₹$balance", Colors.green),
                    ],
                  ),
                ),

                // 🔍 SEARCH + EXPORT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [

                      Expanded(
                        child: TextField(
                          controller: searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: lang.text("Search guest","मेहमान खोजें"),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      goldButton("PDF", Icons.picture_as_pdf, () async {
                        await PdfExport.exportGuests(filtered);
                      }),

                      const SizedBox(width: 6),

                      silverButton("Excel", Icons.table_chart, () async {
                        await ExcelExport.exportGuests(filtered);
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                tableHeader(lang),

                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final g = filtered[i];
                      return tableRow(g, provider, lang);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== UI PARTS ==================

  Widget summaryCard(String title, String value, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.75)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget tableHeader(LanguageService lang) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: card(),
      child: Row(children: [
        Expanded(child: Text(lang.text("Name","नाम"), style: bold())),
        Expanded(child: Text(lang.text("Address","पता"), style: bold())),
        Expanded(child: Text(lang.text("Given","दिया"), style: bold())),
        Expanded(child: Text(lang.text("Taken","लिया"), style: bold())),
        Expanded(child: Text(lang.text("Type","प्रकार"), style: bold())),
        const SizedBox(width: 70),
      ]),
    );
  }

  Widget tableRow(Guest g, GuestProvider provider, LanguageService lang) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: card(),
      child: Row(children: [
        Expanded(child: Text(lang.guestName(en: g.nameEn, hi: g.nameHi))),
        Expanded(child: Text(lang.guestAddress(en: g.addressEn, hi: g.addressHi))),
        Expanded(child: Text("₹${g.given}")),
        Expanded(child: Text("₹${g.taken}")),
        Expanded(
          child: Chip(
            label: Text(g.type),
            backgroundColor: g.type == "Given"
                ? Colors.green.shade100
                : Colors.orange.shade100,
          ),
        ),
        IconButton(icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => editGuestDialog(g, provider)),
        IconButton(icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => provider.deleteGuest(g.id)),
      ]),
    );
  }

  // ================== DIALOG ==================

  void editGuestDialog(Guest g, GuestProvider provider) {
    final nameEn = TextEditingController(text: g.nameEn);
    final nameHi = TextEditingController(text: g.nameHi);
    final given  = TextEditingController(text: g.given.toString());
    final taken  = TextEditingController(text: g.taken.toString());
    String type  = g.type;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Guest"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameEn, decoration: const InputDecoration(labelText: "Name (EN)")),
          TextField(controller: nameHi, decoration: const InputDecoration(labelText: "Name (HI)")),
          TextField(controller: given, decoration: const InputDecoration(labelText: "Given")),
          TextField(controller: taken, decoration: const InputDecoration(labelText: "Taken")),
          DropdownButton<String>(
            value: type,
            items: const [
              DropdownMenuItem(value: "Given", child: Text("Given")),
              DropdownMenuItem(value: "Taken", child: Text("Taken")),
            ],
            onChanged: (v) => type = v!,
          ),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () {
              provider.updateGuest(
                Guest(
                  id: g.id,
                  weddingId: g.weddingId,
                  nameEn: nameEn.text,
                  nameHi: nameHi.text,
                  addressEn: g.addressEn,
                  addressHi: g.addressHi,
                  giftEn: g.giftEn,
                  giftHi: g.giftHi,
                  given: double.tryParse(given.text) ?? 0,
                  taken: double.tryParse(taken.text) ?? 0,
                  type: type,
                  date: g.date,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ================== HELPERS ==================

  TextStyle bold() => const TextStyle(fontWeight: FontWeight.bold);

  BoxDecoration card() => BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      );

  Widget goldButton(String t, IconData i, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(i),
      label: Text(t),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget silverButton(String t, IconData i, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(i),
      label: Text(t),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBDC3C7),
        foregroundColor: Colors.black,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
