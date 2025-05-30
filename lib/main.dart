import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/books/screens/book_list_screen.dart';
import 'features/members/screens/member_list_screen.dart';
import 'features/loans/screens/loan_list_screen.dart';
import 'features/loans/screens/return_screen.dart';
import 'features/settings/screens/setting_screen.dart';
import 'features/settings/screens/notification_screen.dart';
import 'features/settings/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // Gunakan SplashScreen sebagai home
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/books': (context) => const BookListScreen(),
        '/members': (context) => const MemberListScreen(),
        '/loans': (context) => const LoanListScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/returns': (context) => const ReturnScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Tambahkan delay untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 3));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isLoggedIn = token != null && token.isNotEmpty;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6A11CB),
                  Color(0xFF2575FC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                const Icon(
                  Icons.auto_stories_rounded,
                  size: 100,
                  color: Colors.white,
                ).animate().scale(
                  duration: 1000.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 20),

                // App name
                const Text(
                  'PustakaGo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'Sistem Manajemen Perpustakaan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.8),
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}