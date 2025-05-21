import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../settings/history_screen.dart';

class ReturnScreen extends StatefulWidget {
  final int? loanId;

  const ReturnScreen({super.key, this.loanId});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _returnsFuture;

  @override
  void initState() {
    super.initState();
    _loadReturnableBooks();
  }

  void _loadReturnableBooks() {
    setState(() {
      _returnsFuture = apiService.getReturnableLoans();
    });
  }

  Future<void> _returnBook(int loanId) async {
    setState(() {
    });

    try {
      final result = await apiService.returnBook(loanId);
      if (result['success'] == true) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Buku berhasil dikembalikan')),
        );
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal mengembalikan buku: $e')),
      );
    } finally {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: _loadReturnableBooks,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _returnsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada buku yang sedang dipinjam.'));
          }

          final loans = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              final loanId = loan['id'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(loan['book_title'] ?? 'Judul tidak tersedia'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${loan['status']}'),
                      if (loan['loan_date'] != null)
                        Text('Tanggal Pinjam: ${loan['loan_date']}'),
                      if (loan['due_date'] != null)
                        Text('Jatuh Tempo: ${loan['due_date']}'),
                    ],
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () => _returnBook(loanId),
                    icon: const Icon(Icons.keyboard_return),
                    label: const Text("Kembalikan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
