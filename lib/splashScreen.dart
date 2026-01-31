import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/login_screen.dart';
import 'dashboards/CustomerDashboard.dart';
import 'dashboards/SellerDashboard.dart';
import 'dashboards/super_dashboard.dart';


class Splashscreen extends StatefulWidget{
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();

}
class _SplashscreenState extends State<Splashscreen>{
  @override
  void initState() {
    super.initState();

    decideNavigation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold();

  }
  // 1. Give splash animation time to play (3 seconds total)
  Future<void> decideNavigation () async{
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final supabase = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();

    // 2. Check for active session
    final session = supabase.auth.currentSession;

    if (session != null && session.user.role == 'admin') {
      _navigate(const SuperAdminBottomScreen());
      return;
    }else if (session != null && session.user.role == 'seller') {
      _navigate(const SellerDashboardScreen());
      return;
    }else if (session != null && session.user.role == 'customer') {
      _navigate(const CustomerdashboardScreen());
      return;
    }

    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      _navigate(const LoginScreen());
    } else {

      _navigate(const LoginScreen());
    }
  }

  void _navigate(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}