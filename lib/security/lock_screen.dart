import 'package:flutter/material.dart';
import 'pin_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final ctrl = TextEditingController();
  String msg = "";

  @override
  void dispose() {
  ctrl.dispose();
  super.dispose();
}

  Future<void> unlock() async {
    final ok = await PinService.verify(ctrl.text);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() => msg = "Wrong PIN");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Enter App PIN",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: "PIN"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: unlock, child: const Text("Unlock")),
            const SizedBox(height: 10),
            Text(msg, style: const TextStyle(color: Colors.red)),
          ]),
        ),
      ),
    );
  }
}
