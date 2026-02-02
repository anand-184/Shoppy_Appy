import 'package:flutter/material.dart';
import 'package:shoppy_appy/splashScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splashscreen(),
    );
  }
}
