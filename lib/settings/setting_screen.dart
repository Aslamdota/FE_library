import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pastikan EditProfileScreen diimpor
import '../screens/edit_profile_screen.dart'; // Ganti dengan path yang sesuai

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String name = 'Memuat...';
  String email = 'Memuat...';
  String phone = 'Memuat...';
  String address = 'Belum tersedia';
  String avatar = ''; // Tambahkan deklarasi avatar

  @override
  void initState() {
    super.initState();
    _loadSettingsData();
  }

  Future<void> _loadSettingsData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Tidak diketahui';
      email = prefs.getString('email') ?? 'Tidak diketahui';
      phone = prefs.getString('phone') ?? 'Tidak diketahui';
      address = prefs.getString('address') ?? 'Belum tersedia';
      avatar = prefs.getString('avatar') ?? ''; // Ambil avatar
    });
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        backgroundColor: const Color(0xFF8F94FB),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: (avatar.isNotEmpty)
                        ? NetworkImage('http://localhost:8000/storage/$avatar')
                        : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(icon: Icons.email, title: 'Email', subtitle: email),
            _buildInfoTile(icon: Icons.phone, title: 'Telepon', subtitle: phone),
            _buildInfoTile(icon: Icons.home, title: 'Alamat', subtitle: address),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E54C8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final memberId = prefs.getInt('member_id') ?? 0;
                final currentName = prefs.getString('name') ?? '';
                final currentPhone = prefs.getString('phone') ?? '';
                final currentAddress = prefs.getString('address') ?? '';
                
                final updated = await Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      memberId: memberId,
                      name: currentName,
                      phone: currentPhone,
                      address: currentAddress,
                    ),
                  ),
                );
                if (updated == true) {
                  _loadSettingsData(); // Refresh profile data
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
