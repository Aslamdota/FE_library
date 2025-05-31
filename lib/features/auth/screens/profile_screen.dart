import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../settings/screens/setting_screen.dart';
import '../../settings/screens/notification_screen.dart';
import '../../loans/screens/denda_screen.dart';
import '../../settings/screens/history_screen.dart';
import 'package:library_frontend/widgets/member_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Memuat...';
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Tidak diketahui';
      photoUrl = prefs.getString('avatar');
    });
  }

  Widget buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Center(
            child: MemberAvatar(
              photoUrl: photoUrl,
              size: 120,
              borderRadius: BorderRadius.circular(60), // bulat penuh
            ),
          ),
          const SizedBox(height: 24),
          buildProfileOption(
            icon: Icons.lock,
            title: 'Privasi',
            subtitle: 'Pengaturan privasi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
          buildProfileOption(
            icon: Icons.notifications,
            title: 'Notifikasi',
            subtitle: 'Preferensi notifikasi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            ),
          ),
          buildProfileOption(
            icon: Icons.warning,
            title: 'Denda',
            subtitle: 'Informasi dan histori denda',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DendaScreen()),
            ),
          ),
          buildProfileOption(
            icon: Icons.history,
            title: 'Riwayat',
            subtitle: 'Lihat histori peminjaman dan pengembalian',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
