import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../books/screens/book_list_screen.dart';
import '../../loans/screens/loan_list_screen.dart';
import '../../loans/screens/return_screen.dart';
import '../../auth/screens/profile_screen.dart';
import '../../settings/screens/notification_screen.dart';
import '../../../widgets/home_content.dart';
import '../../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  ThemeMode currentTheme = ThemeMode.light;
  late AnimationController _fabAnimationController;
  bool _isFabVisible = true;

  final List<Widget> _screens = [
    const ModernHomeContent(),
    const BookListScreen(),
    const LoanListScreen(),
    const ReturnScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void toggleTheme() {
    setState(() {
      currentTheme = currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> logout() async {
    await ApiService().clearToken();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void contactAdmin() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.contact_support,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "Contact Admin",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                "Email: admin@library.com\nWhatsApp: +62 812-3456-7890",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Close",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _fabAnimationController.forward();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _isFabVisible = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isFabVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: currentTheme,
      routes: {
        '/notifications': (context) => const NotificationScreen(),
      },
      home: Builder(
        builder: (context) => Scaffold(
          extendBody: true,
          appBar: _buildAppBar(context),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuart,
                  )),
                  child: child,
                ),
              );
            },
            child: _screens[_currentIndex],
          ),
          floatingActionButton: _buildFloatingActionButton(),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('📚 PustakaGo').animate().fadeIn().slideX(),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ).animate().fadeIn(delay: 200.ms),
        _buildPopupMenuButton(context),
      ],
    );
  }

  Widget _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'theme') toggleTheme();
        if (value == 'logout') logout();
        if (value == 'contact') {
          _fabAnimationController.reverse().then((_) => contactAdmin());
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'theme',
          child: Row(
            children: [
              Icon(
                currentTheme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
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
              Icon(Icons.help, color: Theme.of(context).iconTheme.color),
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
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget? _buildFloatingActionButton() {
    if (!_isFabVisible) return null;

    return ScaleTransition(
      scale: _fabAnimationController,
      child: FloatingActionButton(
        onPressed: () {
          // Add your FAB action here
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.search, color: Colors.white),
      ).animate().shake(delay: 500.ms),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
          items: [
            _buildBottomNavItem(Icons.home_outlined, Icons.home, 'Home'),
            _buildBottomNavItem(Icons.menu_book_outlined, Icons.menu_book, 'Books'),
            _buildBottomNavItem(Icons.book_outlined, Icons.book, 'Loans'),
            _buildBottomNavItem(Icons.assignment_return_outlined, Icons.assignment_return, 'Returns'),
            _buildBottomNavItem(Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(IconData outlineIcon, IconData filledIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(outlineIcon).animate().fadeIn(),
      activeIcon: Icon(filledIcon).animate().scale(),
      label: label,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.indigo,
        secondary: Colors.indigoAccent,
        background: const Color(0xFFF5F6FA),
        surface: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.indigo,
        secondary: Colors.indigoAccent,
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
    );
  }
}