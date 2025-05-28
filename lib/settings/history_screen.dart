import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history';

  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = apiService.getReturnedLoans();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _loadHistory();
    });
  }

  Future<void> _deleteHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus seluruh riwayat dari tampilan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await apiService.deleteHistory();
      if (success) {
        setState(() {
          _historyFuture = Future.value([]);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat berhasil dihapus')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus riwayat')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengembalian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            tooltip: 'Hapus Semua Riwayat',
            onPressed: _deleteHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHistory,
          child: FutureBuilder<List<dynamic>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Gagal memuat riwayat'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Tidak ada riwayat pengembalian.'));
              }
              final history = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final rawDate = item['return_date'];
                  String returnDate = '-';
                  if (rawDate != null && rawDate.toString().isNotEmpty) {
                    try {
                      final date = DateTime.parse(rawDate);
                      returnDate = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
                    } catch (_) {
                      returnDate = rawDate.toString();
                    }
                  }
                  final memberId = item['member_id']?.toString() ?? '-';
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      key: ValueKey(item['id'] ?? index),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(Icons.book_outlined, color: Colors.blue),
                        title: Text(
                          item['book_title'] ?? 'Judul tidak tersedia',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal dikembalikan: $returnDate'),
                            Text('Member ID: $memberId'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );  
            },
          ),
        ),
      ),
    );
  }
}
