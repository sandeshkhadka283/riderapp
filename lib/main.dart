import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase here
  await Supabase.initialize(
    url: 'https://qkvqajnigyerjccmaack.supabase.co',
    anonKey: 'sb_publishable_3G-ynuAmWKzhrvp28LLfRg_hbUsbuK3',
  );

  runApp(const RideApp());
}

class RideApp extends StatelessWidget {
  const RideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Request Viewer',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/otp': (context) => const OTPScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
