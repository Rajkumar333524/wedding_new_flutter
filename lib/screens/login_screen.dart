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
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();

  // Keyboard focus
  final FocusNode f1 = FocusNode();
  final FocusNode f2 = FocusNode();

  bool loading = false;
  bool isRegister = false;

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    f1.dispose();
    f2.dispose();
    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> submit() async {
    final phoneText = phone.text.trim();
    final passwordText = password.text.trim();

    if (phoneText.isEmpty) {
      message('Please enter mobile number.');
      return;
    }

    if (passwordText.isEmpty) {
      message('Please enter password.');
      return;
    }

    if (passwordText.length < 6) {
      message('Password must be at least 6 characters.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      if (isRegister) {
        // ============================
        // REGISTER
        // ============================

        await AuthService.register(
          phoneText,
          passwordText,
        );

        if (!mounted) return;

        message(
          'Account created successfully. Please login.',
        );

        setState(() {
          isRegister = false;
        });
      } else {
        // ============================
        // LOGIN
        // ============================

        await AuthService.login(
          phoneText,
          passwordText,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const WeddingListScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String error = e.toString();

      if (error.startsWith('Exception: ')) {
        error = error.substring(11);
      }

      message(error);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: GlassPanel(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(26),
                decoration: _card(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ============================
                    // TITLE
                    // ============================

                    const Text(
                      'Wedding Register',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      isRegister
                          ? 'Create New Account'
                          : 'Secure Login',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ============================
                    // PHONE
                    // ============================

                    _field(
                      'Mobile Number',
                      phone,
                      f1,
                      f2,
                      TextInputType.phone,
                    ),

                    const SizedBox(height: 14),

                    // ============================
                    // PASSWORD
                    // ============================

                    _field(
                      'Password',
                      password,
                      f2,
                      null,
                      TextInputType.text,
                      obscure: true,
                      last: true,
                    ),

                    const SizedBox(height: 26),

                    // ============================
                    // MAIN BUTTON
                    // ============================

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: _goldButton(),
                        onPressed: loading ? null : submit,
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                isRegister
                                    ? 'Create Account'
                                    : 'Login',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ============================
                    // LOGIN / REGISTER SWITCH
                    // ============================

                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              setState(() {
                                isRegister = !isRegister;
                                phone.clear();
                                password.clear();
                              });
                            },
                      child: Text(
                        isRegister
                            ? 'Already have account? Login'
                            : 'Create new account',
                      ),
                    ),

                    // ============================
                    // FORGOT PASSWORD
                    // ============================

                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              message(
                                'Forgot Password is not available yet.',
                              );
                            },
                      child: const Text(
                        'Forgot Password',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _field(
    String label,
    TextEditingController controller,
    FocusNode current,
    FocusNode? next,
    TextInputType type, {
    bool obscure = false,
    bool last = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: current,
      keyboardType: type,
      obscureText: obscure,
      textInputAction:
          last ? TextInputAction.done : TextInputAction.next,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // BUTTON STYLE
  // ============================================================

  ButtonStyle _goldButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD4AF37),
      foregroundColor: Colors.black,
      elevation: 14,
      shadowColor: Colors.black54,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // ============================================================
  // CARD STYLE
  // ============================================================

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.88),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 20,
        ),
      ],
    );
  }
}