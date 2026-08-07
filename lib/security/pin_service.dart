import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  static const _pinKey = "app_pin";

  static Future<bool> hasPin() async {
    final p = await SharedPreferences.getInstance();
    return p.containsKey(_pinKey);
  }

  static Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_pinKey, pin);
  }

  static Future<String?> getPin() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_pinKey);
  }

  static Future<bool> verify(String input) async {
    final saved = await getPin();
    return saved == input;
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_pinKey);
  }
}
