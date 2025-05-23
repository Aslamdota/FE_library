import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/book.dart';

class BookListScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const BookListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Book>> _booksFuture;
  String? _memberId;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _booksFuture = _fetchBooks();
    _loadMemberId();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _booksFuture = _fetchBooks();
    });
    try {
      await _booksFuture;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<Book>> _fetchBooks() async {
    final list = widget.categoryId != null
        ? await _apiService.getBooksByCategory(widget.categoryId!)
        : await _apiService.getBooks();
    return list.map((e) => Book.fromJson(e)).toList();
  }

  Future<void> _loadMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _memberId = prefs.getString('member_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.categoryName ?? 'Daftar Buku',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _buildSearchField(theme),
          ),
        ),
      ),
      body: _buildBookList(theme),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari buku...',
        prefixIcon: const Icon(Icons.search_rounded, size: 24),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBookList(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FutureBuilder<List<Book>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString(), theme);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(theme);
        }

        final filteredBooks = snapshot.data!.where(_matchesSearch).toList();

        if (filteredBooks.isEmpty) {
          return _buildNoResultsState(theme);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: filteredBooks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              return _BookCard(
                book: book,
                onTap: () => _showBookDetails(context, book),
              );
            },
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
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBooks,
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
            Icons.menu_book_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada buku tersedia',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.categoryId != null
                ? 'Tidak ada buku dalam kategori ini'
                : 'Belum ada buku yang terdaftar',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBooks,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Buku tidak ditemukan',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada hasil untuk "${_searchController.text}"',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  bool _matchesSearch(Book book) {
    if (_searchQuery.isEmpty) return true;

    final title = book.title.toLowerCase();
    final author = book.author.toLowerCase();
    final category = (book.category?['name'] ?? '').toString().toLowerCase();
    final publisher = (book.publisher ?? '').toLowerCase();

    return title.contains(_searchQuery) ||
        author.contains(_searchQuery) ||
        category.contains(_searchQuery) ||
        publisher.contains(_searchQuery);
  }

  void _showBookDetails(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 12),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return _BookDetailsSheet(
                book: book,
                scrollController: scrollController,
                memberId: _memberId,
                onBorrow: () => _handleBookLoan(context, book),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleBookLoan(BuildContext context, Book book) async {
    try {
      Navigator.pop(context);

      if (_memberId == null || _memberId!.isEmpty) {
        _showSnackBar(context, 'Anda harus login terlebih dahulu');
        return;
      }

      final response = await _apiService.createLoan(_memberId!, book.id);

      if (response['status'] == 'success') {
        _showSnackBar(context, 'Permintaan peminjaman berhasil dibuat');
        await Future.delayed(const Duration(milliseconds: 1500));
        _loadBooks();
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushNamed(context, '/loans');
        }
      } else {
        _showSnackBar(context, response['message'] ?? 'Gagal meminjam buku');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookCard({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 0.7,
                child: book.coverUrl != null
                    ? Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                      )
                    : _buildPlaceholderCover(),
              ),
            ),

            // Book Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Author
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stock
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stok: ${book.stock ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _BookDetailsSheet extends StatelessWidget {
  final Book book;
  final ScrollController scrollController;
  final String? memberId;
  final VoidCallback onBorrow;

  const _BookDetailsSheet({
    required this.book,
    required this.scrollController,
    required this.memberId,
    required this.onBorrow,
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
                // Book cover - constrained to fixed size
                ConstrainedBox(
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
                              errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                            )
                          : _buildPlaceholderCover(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Title and author - constrained to prevent overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: mediaQuery.size.width - 180, // Account for padding and image
                        ),
                        child: Text(
                          book.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
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
            const SizedBox(height: 16),

            // Book details - constrained to prevent overflow
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: mediaQuery.size.width - 48, // Account for padding
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailRow(label: 'Penerbit', value: book.publisher ?? '-'),
                  _DetailRow(label: 'ISBN', value: book.isbn ?? '-'),
                  _DetailRow(
                    label: 'Tahun Terbit',
                    value: book.publicationYear?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Stok Tersedia',
                    value: book.stock?.toString() ?? '0',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Borrow button - fixed at bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: memberId == null ? null : onBorrow,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: memberId == null
                    ? const Text('Login untuk Meminjam')
                    : const Text('Pinjam Buku'),
              ),
            ),
            
            // Add extra padding at bottom for safety
            SizedBox(height: mediaQuery.viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return const Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}