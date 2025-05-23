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

  Widget _buildBookCover(String? imageUrl) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.book,
                  color: Colors.grey[500],
                  size: 30,
                ),
              ),
            )
          : Icon(
              Icons.book,
              color: Colors.grey[500],
              size: 30,
            ),
    );
  }

  Widget _buildLoanStatus(String status, DateTime? dueDate) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'overdue':
        statusColor = Colors.red;
        statusIcon = Icons.warning_amber_rounded;
        statusText = 'Terlambat';
        break;
      case 'due soon':
        statusColor = Colors.orange;
        statusIcon = Icons.timer;
        statusText = 'Jatuh Tempo';
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Aktif';
    }

    return Row(
      children: [
        Icon(statusIcon, color: statusColor, size: 16),
        const SizedBox(width: 4),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (dueDate != null) ...[
          const SizedBox(width: 8),
          Text(
            '| ${dueDate.day}/${dueDate.month}/${dueDate.year}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Buku'),
        centerTitle: true,
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data peminjaman...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat data',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReturnableBooks,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada buku yang dipinjam',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Semua buku telah dikembalikan',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final loans = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final loan = loans[index];
              final bookId = loan['book_id'];
              final memberId = loan['member_id'];
              DateTime? dueDate;
              if (loan['due_date'] != null) {
                dueDate = DateTime.tryParse(loan['due_date']);
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBookCover(loan['book_cover_url']),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan['book_title'] ?? 'Judul tidak tersedia',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loan['book_author'] ?? 'Penulis tidak diketahui',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildLoanStatus(
                                loan['status'] ?? 'active', dueDate),
                            const SizedBox(height: 8),
                            if (loan['loan_date'] != null)
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pinjam: ${loan['loan_date']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ]),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.report_gmailerrorred,
                                color: Colors.red),
                            tooltip: 'Laporkan buku hilang',
                            onPressed: () {
                              if (bookId != null && memberId != null) {
                                _reportLostBook(bookId, memberId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('⚠️ Data tidak lengkap')),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hilang?',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
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