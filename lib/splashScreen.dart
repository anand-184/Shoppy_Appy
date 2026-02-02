import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login_screen.dart';
import 'dashboards/CustomerDashboard.dart';
import 'dashboards/SellerDashboard.dart';
import 'dashboards/super_dashboard.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    /// ✅ Wait for first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  Future<void> _navigate() async {
    /// Short delay for smooth splash (NOT 3s)
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final user = supabase.auth.currentUser;

    if (user == null) {
      _go(const LoginScreen());
      return;
    }

    final role = user.userMetadata?['role'];

    switch (role) {
      case 'admin':
        _go(const SuperAdminBottomScreen());
        break;
      case 'seller':
        _go(const SellerDashboardScreen());
        break;
      default:
        _go(const CustomerdashboardScreen());
    }
  }

  void _go(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
