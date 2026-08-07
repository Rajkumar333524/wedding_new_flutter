class OfflineDictionary {
  static final Map<String, String> _dict = {
    "name": "नाम",
    "address": "पता",
    "gift": "सगुन",
    "father": "पिता",
    "mother": "माता",
    "brother": "भाई",
    "sister": "बहन",
    "village": "गाँव",
    "city": "शहर",
    "cash": "नकद",
    "gold": "सोना",
    "money": "पैसे",
    "given": "दिया",
    "taken": "लिया",
    "son": "बेटा",
    "daughter": "बेटी",
    "uncle": "चाचा",
    "aunt": "चाची",
    "grandfather": "दादा",
    "grandmother": "दादी",
  };

  /// Works fully offline
  static String translate(String text) {
    if (text.trim().isEmpty) return "";

    final words = text.toLowerCase().split(RegExp(r'\s+'));

    return words.map((w) {
      return _dict[w] ?? w;
    }).join(' ');
  }
}
