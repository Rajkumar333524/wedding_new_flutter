import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';
import 'wedding_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final phone = TextEditingController();
  final password = TextEditingController();

  // 🔑 Keyboard focus
  final f1 = FocusNode();
  final f2 = FocusNode();

  bool loading = false;
  bool isRegister = false;
  bool isForgot = false;

  Future<void> submit() async {
    if (phone.text.isEmpty || (!isForgot && password.text.isEmpty)) {
      message("Please fill required fields");
      return;
    }

    setState(() => loading = true);

    try {
      if (isForgot) {
        await AuthService.forgot(phone.text.trim());
        message("Password reset link sent");
      }
      else if (isRegister) {
        await AuthService.register(phone.text.trim(), password.text.trim());
        message("Account created. Please login.");
        setState(() => isRegister = false);
      }
      else {
        await AuthService.login(phone.text.trim(), password.text.trim());
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WeddingListScreen()),
        );
      }
    } catch (e) {
      message("Error: $e");
    }

    if (mounted) setState(() => loading = false);
  }

  void message(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Center(
          child: GlassPanel(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(26),
              decoration: _card(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Wedding Register",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text("Secure Login",
                      style: TextStyle(color: Colors.black54)),

                  const SizedBox(height: 24),

                  _field(
                    "Mobile Number",
                    phone,
                    f1,
                    f2,
                    TextInputType.phone,
                  ),

                  if (!isForgot) ...[
                    const SizedBox(height: 14),
                    _field(
                      "Password",
                      password,
                      f2,
                      null,
                      TextInputType.text,
                      obscure: true,
                      last: true,
                    ),
                  ],

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: _goldButton(),
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              isForgot
                                  ? "Reset Password"
                                  : isRegister
                                      ? "Create Account"
                                      : "Login",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        isRegister = !isRegister;
                        isForgot = false;
                      });
                    },
                    child: Text(isRegister
                        ? "Already have account? Login"
                        : "Create new account"),
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        isForgot = !isForgot;
                        isRegister = false;
                      });
                    },
                    child: const Text("Forgot Password"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _field(String label, TextEditingController c,
      FocusNode current, FocusNode? next, TextInputType type,
      {bool obscure = false, bool last = false}) {
    return TextField(
      controller: c,
      focusNode: current,
      keyboardType: type,
      obscureText: obscure,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      onSubmitted: (_) {
        if (next != null) {
          FocusScope.of(context).requestFocus(next);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  ButtonStyle _goldButton() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        elevation: 14,
        shadowColor: Colors.black54,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 20),
        ],
      );
}
