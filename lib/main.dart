import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/guest.dart';

import 'services/auth_service.dart';
import 'services/hive_service.dart';

import 'security/app_guard.dart';

import 'screens/wedding_list_screen.dart';
import 'screens/add_wedding_screen.dart';

// Future Screens
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/dashboard_screen.dart';
// import 'screens/fast_entry_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===========================
  // Hive Initialization
  // ===========================

  await Hive.initFlutter();

  Hive.registerAdapter(GuestAdapter());

  await HiveService.init();

  await Hive.openBox<Guest>('pendingSync');

  // ===========================
  // Authentication Init
  // ===========================

  await AuthService.init();

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppGuard(
      child: WeddingApp(),
    );
  }
}

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Wedding Register Pro",

      theme: ThemeData(
        useMaterial3: true,

        colorSchemeSeed: Colors.deepOrange,

        scaffoldBackgroundColor: Colors.white,
      ),

      initialRoute: "/",

      routes: {
        "/": (context) => const WeddingListScreen(),

        "/add-wedding": (context) => const AddWeddingScreen(),

        // Future
        // "/login": (context)=>const LoginScreen(),
        // "/register": (context)=>const RegisterScreen(),
        // "/dashboard": (context)=>const DashboardScreen(),
        // "/fast-entry": (context)=>const FastEntryScreen(),
      },
    );
  }
}