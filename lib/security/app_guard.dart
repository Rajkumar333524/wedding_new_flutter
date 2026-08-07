import 'package:flutter/material.dart';
import 'pin_service.dart';
import 'lock_screen.dart';

class AppGuard extends StatefulWidget {
  final Widget child;
  const AppGuard({super.key, required this.child});

  @override
  State<AppGuard> createState() => _AppGuardState();
}

class _AppGuardState extends State<AppGuard>
    with WidgetsBindingObserver {

  bool locked = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void checkLock() async {
    final hasPin = await PinService.hasPin();
    setState(() => locked = hasPin);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkLock();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!locked) return widget.child;
    return const LockScreen();
  }
}
