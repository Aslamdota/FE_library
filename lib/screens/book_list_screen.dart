// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<dynamic>> _booksFuture;
  String? _memberId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadBooks();
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

  void _loadBooks() {
    setState(() {
      if (widget.categoryId != null) {
        _booksFuture = apiService.getBooksByCategory(widget.categoryId!);
      } else {
        _booksFuture = apiService.getBooks();
      }
    });
  }

  Future<void> _loadMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getString('member_id');
    if (memberId != null) {
      setState(() {
        _memberId = memberId;
      });
    }
  }

  void _showBookDetails(BuildContext context, Map<String, dynamic> book) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                          child: book['cover_image'] != null && book['cover_image'].toString().isNotEmpty
                            ? Image.network(
                                book['cover_image'].toString().startsWith('http')
                                    ? book['cover_image']
                                    : 'http://127.0.0.1:8000/storage/${book['cover_image']}',
                                width: 80,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 80,
                                      height: 110,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 40),
                                    ),
                              )
                            : Container(
                                width: 80,
                                height: 110,
                                color: Colors.grey[300],
                                child: const Icon(Icons.menu_book, size: 40),
                              ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['title'] ?? 'Tanpa Judul',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book['author'] ?? '-',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 12),
                  _infoRow('Penerbit', book['publisher'], textColor),
                  _infoRow('ISBN', book['isbn'], textColor),
                  _infoRow('Tahun Terbit', book['publication_year']?.toString(), textColor),
                  _infoRow('Stok Tersedia', book['stock']?.toString(), textColor),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleBookLoan(context, book),
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text('Pinjam Buku'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleBookLoan(BuildContext context, Map<String, dynamic> book) async {
    try {
      Navigator.pop(context);

      if (_memberId == null || _memberId!.isEmpty) {
        _showSnackBar(context, 'Anda harus login terlebih dahulu');
        return;
      }

      final response = await apiService.createLoan(_memberId!, book['id']);

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
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _infoRow(String label, String? value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, dynamic book) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showBookDetails(context, book),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book['cover_image'] != null && book['cover_image'].toString().isNotEmpty
                  ? Image.network(
                      book['cover_image'].toString().startsWith('http')
                          ? book['cover_image']
                          : 'http://127.0.0.1:8000/storage/${book['cover_image']}',
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            width: double.infinity,
                            height: 140,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 140,
                      color: Colors.grey[300],
                      child: const Icon(Icons.menu_book, size: 48),
                    ),
            ),
            const SizedBox(height: 10),

            // Judul
            Text(
              book['title'] ?? 'Tanpa Judul',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),

            // Penulis
            Text(
              book['author'] ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.primary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),

            // Stok
            Row(
              children: [
                Icon(Icons.inventory_2, size: 15, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Stok: ${book['stock']?.toString() ?? '0'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesSearch(dynamic book) {
    if (_searchQuery.isEmpty) return true;

    final title = (book['title'] ?? '').toString().toLowerCase();
    final author = (book['author'] ?? '').toString().toLowerCase();
    final category = (book['category'] ?? '').toString().toLowerCase();
    final publisher = (book['publisher'] ?? '').toString().toLowerCase();

    return title.contains(_searchQuery) ||
        author.contains(_searchQuery) ||
        category.contains(_searchQuery) ||
        publisher.contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        elevation: 0,
        title: widget.categoryName != null
            ? Text('Kategori: ${widget.categoryName}')
            : const Text('📚 Daftar Buku'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadBooks();
              _loadMemberId();
            },
          ),
        ],
      ),
            body: FutureBuilder<List<dynamic>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada buku yang tersedia.'));
          }

          final filteredBooks =
              snapshot.data!.where((book) => _matchesSearch(book)).toList();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari judul, penulis, atau penerbit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // List Buku
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredBooks.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.6,
                    ),
                    itemBuilder: (context, index) {
                      return _buildBookCard(context, filteredBooks[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
