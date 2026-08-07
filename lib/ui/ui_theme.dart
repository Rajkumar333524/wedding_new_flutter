import 'package:flutter/material.dart';

class PremiumTheme {

  // 🌟 Gold Primary Button
  static final ButtonStyle goldButton = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFD4AF37),
    foregroundColor: Colors.black,
    elevation: 16,
    shadowColor: const Color(0xFFFFE9A6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFFFE8A3), width: 1.4),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.8,
    ),
  );

  // 🥈 Silver Secondary Button
  static final ButtonStyle silverButton = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFD6DBDF),
    foregroundColor: Colors.black,
    elevation: 12,
    shadowColor: const Color(0xFFEAECEE),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFF2F3F4), width: 1.2),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );

  // 🟣 Accent Purple (for export / premium actions)
  static final ButtonStyle purpleButton = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF7D3C98),
    foregroundColor: Colors.white,
    elevation: 14,
    shadowColor: Colors.purpleAccent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
  );

  // 🟠 Orange Highlight Button
  static final ButtonStyle orangeButton = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE67E22),
    foregroundColor: Colors.white,
    elevation: 13,
    shadowColor: Colors.orangeAccent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
  );
}
