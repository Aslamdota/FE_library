import 'package:flutter/material.dart';
import 'book_list_screen.dart';
import 'loan_list_screen.dart';
import 'return_screen.dart';
import 'profile_screen.dart';
import '../settings/notification_screen.dart';
import '../widgets/home_content.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  ThemeMode currentTheme = ThemeMode.light;

  final List<Widget> _screens = [
    const ModernHomeContent(),
    const BookListScreen(),
    const LoanListScreen(),
    const ReturnScreen(loanId: 0),
    const ProfileScreen(),
  ];

  void toggleTheme() {
    setState(() {
      currentTheme = currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void logout() async {
    await ApiService().clearToken();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  void contactAdmin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "Contact",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          "Email: admin@library.com\nWhatsApp: +62 812-3456-7890",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.indigo,
          secondary: Colors.indigoAccent,
          background: const Color(0xFFF5F6FA),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF181A20),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.indigo,
          secondary: Colors.indigoAccent,
          background: const Color(0xFF181A20),
          surface: const Color(0xFF1F1F1F),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: currentTheme,
      routes: {
        '/notifications': (context) => const NotificationScreen(),
        // Tambahkan route lain jika perlu
      },
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('📚 Library App'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: Theme.of(context).colorScheme.surface,
                onSelected: (value) {
                  if (value == 'theme') toggleTheme();
                  if (value == 'logout') logout();
                  if (value == 'contact') contactAdmin();
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          currentTheme == ThemeMode.light ? Icons.nightlight_round : Icons.wb_sunny,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 10),
                        Text(currentTheme == ThemeMode.light ? 'Dark Mode' : 'Light Mode'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'contact',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Theme.of(context).iconTheme.color),
                        const SizedBox(width: 10),
                        const Text('Contact Admin'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
                        const SizedBox(width: 10),
                        const Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _screens[_currentIndex],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedFontSize: 14,
                unselectedFontSize: 12,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Theme.of(context).unselectedWidgetColor,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Books'),
                  BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Loans'),
                  BottomNavigationBarItem(icon: Icon(Icons.assignment_return), label: 'Returns'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}