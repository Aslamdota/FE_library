import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../settings/lost_report_screen.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

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

  void _reportLostBook(int bookId, int memberId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LostReportScreen(
          bookId: bookId,
          memberId: memberId,
        ),
      ),
    );
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
            return Center(child: Text('❌ Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('📭 Tidak ada buku yang sedang dipinjam.'));
          }

          final loans = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              final bookId = loan['book_id'];
              final memberId = loan['member_id'];

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
                    onPressed: () {
                      if (bookId != null && memberId != null) {
                        _reportLostBook(bookId, memberId);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⚠️ Data tidak lengkap')),
                        );
                      }
                    },
                    icon: const Icon(Icons.report_gmailerrorred),
                    label: const Text("Buku Hilang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
