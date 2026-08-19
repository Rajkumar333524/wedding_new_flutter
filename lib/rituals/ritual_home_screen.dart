import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

import 'paupuji_screen.dart';
import 'groom_screen.dart';
import 'paupuji_register_screen.dart';
import 'groom_register_screen.dart';

class RitualHomeScreen extends StatefulWidget {
  const RitualHomeScreen({super.key});

  @override
  State<RitualHomeScreen> createState() => _RitualHomeScreenState();
}

class _RitualHomeScreenState extends State<RitualHomeScreen> {
  final FocusNode f1 = FocusNode();
  final FocusNode f2 = FocusNode();
  final FocusNode f3 = FocusNode();
  final FocusNode f4 = FocusNode();

  @override
void dispose() {
  f1.dispose();
  f2.dispose();
  f3.dispose();
  f4.dispose();
  super.dispose();
}

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => FocusScope.of(context).requestFocus(f1));
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("🪔 Ritual & Rasham"),
          backgroundColor: Colors.black.withOpacity(0.35),
          elevation: 0,
        ),

       body: Stack(
  children: [

    Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 12,
        ),
        child: GlassPanel(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.68,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: _card(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    const SizedBox(height: 5),

                    const Text(
                      "Ritual Dashboard",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _btn(
                      "🧧 Paupuji Entry",
                      _gold,
                      f1,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaupujiScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    _btn(
                      "📜 Paupuji Register",
                      _silver,
                      f2,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PaupujiRegisterScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    _btn(
                      "🤵 Groom / Jijaji Entry",
                      _royalPurple,
                      f3,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GroomScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    _btn(
                      "📒 Groom Register",
                      _softGold,
                      f4,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const GroomRegisterScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ],
),
        ),
      ),
    );
  }

  // ================= BUTTON =================

  Widget _btn(String text, Color color, FocusNode focus, VoidCallback onTap) {
    return Focus(
      focusNode: focus,
      onKey: (_, e) {
        if (e is RawKeyDownEvent && e.logicalKey == LogicalKeyboardKey.enter) {
          onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: double.infinity,
         child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 12,
            shadowColor: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  // ================= UI THEME =================

  static const Color _gold = Color(0xffD4AF37);
  static const Color _silver = Color(0xffC0C0C0);
  static const Color _softGold = Color(0xffE6C870);
  static const Color _royalPurple = Color(0xff6A1B9A);

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 18, offset: Offset(0, 10))
        ],
      );
}
