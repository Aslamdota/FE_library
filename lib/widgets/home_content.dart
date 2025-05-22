import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ModernHomeContent extends StatefulWidget {
  const ModernHomeContent({super.key});

  @override
  State<ModernHomeContent> createState() => _ModernHomeContentState();
}

class _ModernHomeContentState extends State<ModernHomeContent> {
  final ApiService apiService = ApiService();

  late Future<List<dynamic>> _recommendationFuture;
  late Future<Map<String, dynamic>> _statsFuture;

  String memberName = 'Member';
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _recommendationFuture = apiService.getLatestBooks();
    _statsFuture = apiService.getStats();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final photo = prefs.getString('avatar');

    if (mounted) {
      setState(() {
        if (name?.isNotEmpty == true) memberName = name!;
        if (photo?.isNotEmpty == true) photoUrl = photo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(context),
          const SizedBox(height: 32),
          _buildStatHeader(context),
          const SizedBox(height: 16),
          _buildStatisticsCard(),
          const SizedBox(height: 32),
          _buildRecommendationHeader(context),
          const SizedBox(height: 16),
          _buildRecommendationList(),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    const double avatarRadius = 24.0; // Ukuran kecil dan konsisten

    return Row(
      children: [
        ClipOval(
          child: (photoUrl != null && photoUrl!.isNotEmpty)
              ? Image.network(
                  'http://localhost:8000/storage/$photoUrl',
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          photoUrl = '';
                        });
                      }
                    });
                    return Image.asset(
                      'assets/images/profile_placeholder.png',
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(
                  'assets/images/profile_placeholder.png',
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, $memberName 👋',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selamat datang di Perpustakaan!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildStatHeader(BuildContext context) {
    return Text(
      '📊 Statistik Hari Ini',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
    );
  }

  Widget _buildStatisticsCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Gagal memuat statistik.'));
        }

        final stats = snapshot.data!;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _statItem(Icons.library_books, 'Total Buku', stats['book'] ?? 0, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _statItem(Icons.person, 'Total Anggota', stats['member'] ?? 0, Colors.teal)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _statItem(Icons.book_online, 'Dipinjam', stats['loan'] ?? 0, Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _statItem(Icons.assignment_turned_in, 'Dikembalikan', stats['return'] ?? 0, Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationHeader(BuildContext context) {
    return Text(
      '📚 Rekomendasi Buku',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRecommendationList() {
    return FutureBuilder<List<dynamic>>(
      future: _recommendationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat rekomendasi buku.'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada rekomendasi buku.'));
        }

        final books = snapshot.data!;
        return Column(
          children: books.take(5).map((book) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1.5,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book['cover'] != null
                      ? Image.network(
                          book['cover'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, color: Colors.grey);
                          },
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: Colors.indigo.withOpacity(0.1),
                          child: const Icon(Icons.menu_book, color: Colors.indigo),
                        ),
                ),
                title: Text(
                  book['title'] ?? 'Tanpa Judul',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(book['author'] ?? '-', style: const TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  // Navigasi ke detail buku di sini jika ada
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _statItem(IconData icon, String label, int value, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }
}
