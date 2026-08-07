class LanguageService {
  static bool _isHindi = true;

  // 🔤 Current language
  static bool get isHindi => _isHindi;
  static bool get isEnglish => !_isHindi;

  // 🔁 Switch language
  static void toggleLanguage() {
    _isHindi = !_isHindi;
  }

  static void setHindi() {
    _isHindi = true;
  }

  static void setEnglish() {
    _isHindi = false;
  }

  // 📝 Universal text selector
  static String text(String en, String hi) {
    return _isHindi ? hi : en;
  }

  // 🧾 Guest helper
  static String guestName({required String en, required String hi}) {
    return _isHindi ? hi : en;
  }

  static String guestAddress({required String en, required String hi}) {
    return _isHindi ? hi : en;
  }

  static String giftName({required String en, required String hi}) {
    return _isHindi ? hi : en;
  }
}
