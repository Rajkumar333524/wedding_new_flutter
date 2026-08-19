import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/guest.dart';

import 'services/auth_service.dart';
import 'services/hive_service.dart';

import 'security/app_guard.dart';

import 'screens/wedding_list_screen.dart';
import 'screens/add_wedding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/about_developer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // HIVE INITIALIZATION
  // ============================================================

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(GuestAdapter());
  }

  await HiveService.init();

  // Offline pending sync
  if (!Hive.isBoxOpen('pendingSync')) {
    await Hive.openBox<Guest>('pendingSync');
  }

  // ============================================================
  // AUTHENTICATION INITIALIZATION
  // ============================================================

  await AuthService.init();

  runApp(const AppRoot());
}

// ============================================================
// APP ROOT
// ============================================================

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppGuard(
      child: WeddingApp(),
    );
  }
}

// ============================================================
// WEDDING APP
// ============================================================

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = AuthService.isLoggedIn();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Wedding Register Pro',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white,
      ),

      home: loggedIn
          ? const WeddingListScreen()
          : const LoginScreen(),

      routes: {
        '/login': (_) => const LoginScreen(),

        '/': (_) => loggedIn
            ? const WeddingListScreen()
            : const LoginScreen(),

        '/add-wedding': (_) => const AddWeddingScreen(),
        '/about': (_) => const AboutDeveloperScreen(),
      },
    );
  }
}
