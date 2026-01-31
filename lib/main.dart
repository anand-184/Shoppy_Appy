import 'package:flutter/material.dart';
import 'package:shoppy_appy/dashboards/CustomerDashboard.dart';
import 'package:shoppy_appy/dashboards/SellerDashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'auth/login_screen.dart';
import 'dashboards/super_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nkfutrocdqvkhsqfwnrp.supabase.co',
    anonKey: 'sb_publishable_zh78wR2LLAKwvOph7QDg_Q_GmedMPcu',
  );



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared Color Palette
    const Color backgroundColor = Color(0xFFFDF8F5);
    const Color brown = Color(0xFFB08968);
    const Color darkBrown = Color(0xFF5F372B);
    const Color chocolate = Color(0xFF915F41);
    
    // Check if initialized before accessing instance
    final supabase = Supabase.instance.client;


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shoppy Appy',
      home: supabase.auth.currentUser == null
    ? const LoginScreen()
        : supabase.auth.currentUser!.userMetadata?['role'] == 'admin'
    ? const SuperAdminBottomScreen()
        : supabase.auth.currentUser!.userMetadata?['role'] == 'seller'
    ? const SellerDashboardScreen()
        : const CustomerdashboardScreen(),

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: chocolate,
          primary: chocolate,
          secondary: brown,
          surface: backgroundColor,
          onSurface: darkBrown,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: darkBrown),
          bodyMedium: TextStyle(color: brown),
          titleMedium: TextStyle(color: darkBrown, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: chocolate,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEADBC8), width: 1.5),
          ),
          prefixIconColor: chocolate,
          hintStyle: TextStyle(color: brown.withOpacity(0.5)),
        ),
      ),
    );
  }
}
