import 'dart:convert';
import 'package:http/http.dart' as http;
import 'offline_dictionary.dart';

class TranslatorService {

  static final Map<String, String> _offlineDict = {
    "sanu": "सानू",
    "naini": "नैनी",
    "sall": "साल",
    "gift": "सगुन",
    "car": "गाड़ी",
    "village": "गाँव",
    "city": "शहर",
    "house": "घर",
    "father": "पिता",
    "mother": "माता",
  };

  static String _basicOffline(String text) {
    return text
        .split(" ")
        .map((w) => _offlineDict[w.toLowerCase()] ?? w)
        .join(" ");
  }

  static Future<String> smartTranslate(String text) async {
    text = text.trim();
    if (text.isEmpty) return "";

    // 🧱 Step 1: Always try offline first
    final offline = _basicOffline(text);

    // 🌐 Step 2: Online (best effort)
    try {
      final res = await http.post(
        Uri.parse("https://libretranslate.de/translate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "q": text,
          "source": "en",
          "target": "hi",
          "format": "text"
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final out = jsonDecode(res.body)['translatedText']?.toString();
        if (out != null && out.isNotEmpty) return out;
      }
    } catch (_) {}

    // 🧯 Step 3: Your custom dictionary
    final custom = OfflineDictionary.translate(text);
    if (custom.trim().isNotEmpty && custom != text) return custom;

    // 🧬 Step 4: At minimum return offline result
    return offline;
  }
}
