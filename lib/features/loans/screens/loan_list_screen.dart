import 'package:flutter/material.dart';
import 'package:library_frontend/models/book.dart';
import '../../../services/api_service.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _loansFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    try {
      _loansFuture = apiService.getLoans();
      await _loansFuture;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Peminjaman'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLoans,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<dynamic>>(
              future: _loansFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString(), theme);
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return _buildLoanList(snapshot.data!, theme);
              },
            ),
    );
  }

  Widget _buildLoanList(List<dynamic> loans, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadLoans,
      color: theme.colorScheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: loans.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final loan = loans[index];
          // Buat objek Book dari data loan
          final book = Book(
            id: loan['book_id'] ?? 0,
            title: loan['book_title'] ?? '',
            author: loan['book_author'] ?? '',
            coverPath: loan['cover_url'],
          );
          return _LoanCard(
            book: book,
            loan: loan,
            onTap: () => _showLoanDetails(context, loan, book),
          );
        },
      ),
    );
  }

  void _showLoanDetails(BuildContext context, dynamic loan, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return _LoanDetailsSheet(
                  loan: loan,
                  book: book,
                  scrollController: scrollController,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data peminjaman',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadLoans,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada peminjaman',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Anda belum memiliki riwayat peminjaman',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/books'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Pinjam Buku'),
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Book book;
  final dynamic loan;
  final VoidCallback onTap;

  const _LoanCard({
    required this.book,
    required this.loan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Status styling
    final statusInfo = _getStatusInfo(loan['status'], isDark);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover with Hero animation - matching book list style
              Hero(
                tag: 'book-cover-${book.id}',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 100,
                    maxHeight: 150,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: colorScheme.surfaceVariant,
                      child: book.coverUrl != null
                          ? Image.network(
                              book.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholderCover(colorScheme),
                            )
                          : _buildPlaceholderCover(colorScheme),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Loan Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Title
                    Text(
                      loan['book_title'] ?? 'Judul tidak tersedia',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Status
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusInfo.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${loan['status']}',
                          style: TextStyle(
                            color: statusInfo.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Dates
                    _buildDateRow(
                      icon: Icons.calendar_today,
                      label: 'Pinjam',
                      date: loan['loan_date'],
                      theme: theme,
                    ),
                    if (loan['due_date'] != null)
                      _buildDateRow(
                        icon: Icons.timer,
                        label: 'Jatuh tempo',
                        date: loan['due_date'],
                        theme: theme,
                        isWarning: loan['status'] == 'Dipinjam' &&
                            DateTime.parse(loan['due_date'])
                                .isBefore(DateTime.now()),
                      ),
                    if (loan['return_date'] != null)
                      _buildDateRow(
                        icon: Icons.check_circle,
                        label: 'Dikembalikan',
                        date: loan['return_date'],
                        theme: theme,
                        isSuccess: true,
                      ),

                    const SizedBox(height: 8),

                    // Action Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildActionButton(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required String? date,
    required ThemeData theme,
    bool isWarning = false,
    bool isSuccess = false,
  }) {
    if (date == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSuccess
                ? Colors.green
                : isWarning
                    ? Colors.orange
                    : theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $date',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSuccess
                  ? Colors.green
                  : isWarning
                      ? Colors.orange
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final status = loan['status'];

    if (status == 'Approved') {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/pickup',
            arguments: {'loanId': loan['id']},
          );
        },
        icon: const Icon(Icons.local_library, size: 18),
        label: const Text('Ambil Buku'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );
    } else if (status == 'Dipinjam') {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/returns',
            arguments: {'loanId': loan['id']},
          );
        },
        icon: const Icon(Icons.assignment_return, size: 18),
        label: const Text('Kembalikan'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );
    } else if (status == 'Rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 16, color: Colors.red),
            SizedBox(width: 4),
            Text(
              'Ditolak',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox(); // Other statuses: Returned, Canceled, etc.
    }
  }

  Widget _buildPlaceholderCover(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 40,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status, bool isDark) {
    switch (status) {
      case 'Approved':
        return _StatusInfo(Colors.green, 'Disetujui');
      case 'Dipinjam':
        return _StatusInfo(Colors.blue, 'Dipinjam');
      case 'Rejected':
        return _StatusInfo(Colors.red, 'Ditolak');
      case 'Returned':
        return _StatusInfo(Colors.grey, 'Dikembalikan');
      default:
        return _StatusInfo(isDark ? Colors.white70 : Colors.black54, status);
    }
  }
}

class _StatusInfo {
  final Color color;
  final String label;

  _StatusInfo(this.color, this.label);
}

class _LoanDetailsSheet extends StatelessWidget {
  final dynamic loan;
  final Book book;
  final ScrollController scrollController;

  const _LoanDetailsSheet({
    required this.loan,
    required this.book,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Book header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover - Hero animation
                Hero(
                  tag: 'book-cover-${book.id}',
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 100,
                      maxHeight: 150,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: colorScheme.surfaceVariant,
                        child: book.coverUrl != null
                            ? Image.network(
                                book.coverUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholderCover(colorScheme),
                              )
                            : _buildPlaceholderCover(colorScheme),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Title and author
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.author,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Divider
            Divider(color: colorScheme.outline.withOpacity(0.2)),
            const SizedBox(height: 24),

            // Book Title
            Text(
              loan['book_title'] ?? 'Judul tidak tersedia',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Author
            Text(
              loan['book_author'] ?? 'Penulis tidak tersedia',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Divider
            Divider(color: theme.dividerColor.withOpacity(0.2)),
            const SizedBox(height: 16),

            // Loan Details
            _DetailItem(
              icon: Icons.calendar_today,
              label: 'Tanggal Pinjam',
              value: loan['loan_date'] ?? '-',
            ),
            _DetailItem(
              icon: Icons.timer,
              label: 'Jatuh Tempo',
              value: loan['due_date'] ?? '-',
            ),
            ...(loan['return_date'] != null
                ? [
                    _DetailItem(
                      icon: Icons.check_circle,
                      label: 'Tanggal Kembali',
                      value: loan['return_date']!,
                      isSuccess: true,
                    ),
                  ]
                : []),
            _DetailItem(
              icon: Icons.info,
              label: 'Status',
              value: loan['status'] ?? '-',
              isStatus: true,
            ),
            const SizedBox(height: 24),

            // Bottom Button
            Padding(
              padding: EdgeInsets.only(
                bottom: 24 + mediaQuery.viewInsets.bottom,
                left: 0,
                right: 0,
                top: 12,
              ),
              child: _buildActionButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final status = loan['status'];

    if (status == 'Approved') {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/pickup',
            arguments: {'loanId': loan['id']},
          );
        },
        icon: const Icon(Icons.local_library, size: 20),
        label: const Text('Ambil Buku'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (status == 'Dipinjam') {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/returns',
            arguments: {'loanId': loan['id']},
          );
        },
        icon: const Icon(Icons.assignment_return, size: 20),
        label: const Text('Kembalikan Buku'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildPlaceholderCover(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No Cover',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isStatus;
  final bool isSuccess;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isStatus = false,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? valueColor;

    if (isStatus) {
      switch (value.toLowerCase()) {
        case 'approved':
          valueColor = Colors.green;
          break;
        case 'dipinjam':
          valueColor = Colors.blue;
          break;
        case 'rejected':
          valueColor = Colors.red;
          break;
        case 'returned':
          valueColor = Colors.grey;
          break;
      }
    } else if (isSuccess) {
      valueColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSuccess
                ? Colors.green
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? theme.textTheme.bodyMedium?.color,
                    fontWeight: isStatus ? FontWeight.w500 : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}