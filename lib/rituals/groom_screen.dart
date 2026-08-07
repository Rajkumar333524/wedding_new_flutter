import 'package:flutter/material.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';
import '../rituals/ritual_service.dart';


class GroomScreen extends StatefulWidget {
  const GroomScreen({super.key});

  @override
  State<GroomScreen> createState() => _GroomScreenState();
}

class _GroomScreenState extends State<GroomScreen> {

  final name = TextEditingController();
  final gift = TextEditingController();
  final money = TextEditingController();

  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();

  bool saving = false;

  Future<void> save() async {
    if (name.text.isEmpty) return;

    setState(() => saving = true);

    await RitualService.saveGroomEntry(
      name: name.text.trim(),
      gift: gift.text.trim(),
      money: double.tryParse(money.text) ?? 0,
    );

    name.clear();
    gift.clear();
    money.clear();

    FocusScope.of(context).requestFocus(f1);

    setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("🤵 Groom / Jijaji Gifts"),
          backgroundColor: Colors.black.withOpacity(0.4),
        ),

        body: Center(
          child: GlassPanel(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(22),
              decoration: _card(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text("Groom Entry",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 16),

                  _field("Name", name, f1, f2),
                  _field("Gift", gift, f2, f3),
                  _field("Money", money, f3, null, number: true),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving ? null : save,
                      style: _btnStyle(),
                      child: saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Entry"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, FocusNode current,
      FocusNode? next, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        focusNode: current,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        textInputAction: next == null ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (_) {
          if (next != null) {
            FocusScope.of(context).requestFocus(next);
          } else {
            save();
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

  BoxDecoration _card() => BoxDecoration(
    color: Colors.white.withOpacity(0.88),
    borderRadius: BorderRadius.circular(18),
    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 15)],
  );

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xffC62828),
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 10,
  );
}
