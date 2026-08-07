import 'package:flutter/material.dart';
import '../widgets/app_frame.dart';
import '../services/api_service.dart';
import '../models/wedding.dart';

class Page1WeddingCreate extends StatefulWidget {
  const Page1WeddingCreate({super.key});

  @override
  State<Page1WeddingCreate> createState() => _Page1WeddingCreateState();
}

class _Page1WeddingCreateState extends State<Page1WeddingCreate> {

  final bride = TextEditingController();
  final groom = TextEditingController();
  final location = TextEditingController();
  final date = TextEditingController();

  // 🔑 Keyboard Focus
  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();

  bool saving = false;

  Future<void> saveAndNext() async {
    if (bride.text.isEmpty || groom.text.isEmpty || location.text.isEmpty || date.text.isEmpty) {
      _msg("All fields required");
      return;
    }

    setState(() => saving = true);

    try {
      final wedding = Wedding(
        id: DateTime.now().millisecondsSinceEpoch,
        brideNameEn: bride.text.trim(),
        groomNameEn: groom.text.trim(),
        brideNameHi: bride.text.trim(),
        groomNameHi: groom.text.trim(),
        location: location.text.trim(),
        date: date.text.trim(),
      );

      await ApiService.addWeddingObject(wedding);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Page2GuestEntry(wedding: wedding),
        ),
      );
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
    return AppFrame(
      child: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(26),
          decoration: _card(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text("💍 Create Wedding",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 18),

              _field("Bride Name / दुल्हन का नाम", bride, f1, f2),
              _field("Groom Name / दूल्हे का नाम", groom, f2, f3),
              _field("Location / स्थान", location, f3, f4),
              _field("Date (YYYY-MM-DD)", date, f4, null, last: true),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _goldButton(),
                  onPressed: saving ? null : saveAndNext,
                  child: saving
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Save & Next",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _field(String label, TextEditingController c,
      FocusNode current, FocusNode? next,
      {bool last = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        focusNode: current,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (_) {
          if (next != null) {
            FocusScope.of(context).requestFocus(next);
          } else {
            saveAndNext();
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

  ButtonStyle _goldButton() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        elevation: 14,
        shadowColor: Colors.black54,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 14),
        ],
      );
}
