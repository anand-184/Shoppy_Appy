import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login_screen.dart';
import 'dashboards/SellerDashboard.dart';
import 'dashboards/super_dashboard.dart';
import 'dashboards/main_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // Short delay for visual polish
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final user = supabase.auth.currentUser;

    if (user == null) {
      _navigateTo(const LoginScreen());
      return;
    }

    try {
      // Fetch user role from your 'users' table
      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final String role = response['role'] ?? 'customer';

      if (role == 'admin') {
        _navigateTo(const SuperAdminBottomScreen());
      } else if (role == 'seller') {
        _navigateTo(const SellerDashboardScreen());
      } else {
        _navigateTo(const MainScreen());
      }
    } catch (e) {
      // Fallback to login if something goes wrong (e.g. no internet or role not found)
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFDF8F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Shoppy Appy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5F372B),
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFF915F41)),
          ],
        ),
      ),
    );
  }
}
