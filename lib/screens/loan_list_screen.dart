import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _loansFuture;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  void _loadLoans() {
    setState(() {
      _loansFuture = apiService.getLoans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Peminjaman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLoans,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _loansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat data peminjaman'),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadLoans,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada peminjaman yang tersedia.'),
            );
          } else {
            final loans = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.library_books),
                    title: Text(loan['book_title'] ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${loan['status']}'),
                        if (loan['loan_date'] != null)
                          Text('Tanggal Pinjam: ${loan['loan_date']}'),
                      ],
                    ),
                    trailing: _buildActionButton(loan),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildActionButton(dynamic loan) {
    if (loan['status'] == 'Approved') {
      return ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/pickup',
            arguments: {'loanId': loan['id']},
          );
        },
        child: const Text('Ambil Buku'),
      );
    } else if (loan['status'] == 'Dipinjam') {
      return ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/returns',
            arguments: {'loanId': loan['id']},
          );
        },
        child: const Text('Kembalikan Buku'),
      );
    } else if (loan['status'] == 'Rejected') {
      return const Text(
        'Ditolak',
        style: TextStyle(color: Colors.red),
      );
    } else {
      return const SizedBox(); // Status lain: Returned, Canceled, dll
    }
  }
}
