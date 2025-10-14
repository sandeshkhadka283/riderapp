import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
// keep if needed

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if needed
  await Supabase.initialize(
    url: 'https://qkvqajnigyerjccmaack.supabase.co',
    anonKey: 'sb_publishable_3G-ynuAmWKzhrvp28LLfRg_hbUsbuK3',
  );

  // ✅ Check saved token
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('accessToken');

  runApp(RideApp(accessToken: accessToken));
}

class RideApp extends StatelessWidget {
  final String? accessToken;

  const RideApp({super.key, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Request Viewer',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      // Auto navigate depending on accessToken
      initialRoute: accessToken != null ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // OTP screen handled in Login -> OTP flow
      },
    );
  }
}

/// ✅ Splash screen to check Supabase session
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(
      const Duration(milliseconds: 2000),
    ); // Small delay for feel

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // ✅ User already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // ❌ Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.red)),
    );
  }
}
