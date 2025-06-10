import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../features/books/widgets/book_detail_sheet.dart';
import '../models/book.dart'; 

class ModernHomeContent extends StatefulWidget {
  const ModernHomeContent({super.key});

  @override
  State<ModernHomeContent> createState() => _ModernHomeContentState();
}

class _ModernHomeContentState extends State<ModernHomeContent> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<dynamic>> _booksByCategoryFuture;
  String memberName = 'Member';
  String? photoUrl;
  final double _avatarRadius = 28.0;
  List<dynamic> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _statsFuture = apiService.getStats();
    _loadUserData();
    _loadCategories();
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

  Future<void> _loadCategories() async {
    final categories = await apiService.getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories[0]['id'];
          _booksByCategoryFuture = apiService.getBooksByCategory(_selectedCategoryId!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? theme.colorScheme.surface : const Color(0xFFE3F0FF);
    final textColor = isDarkMode ? theme.colorScheme.onBackground : Colors.black87;
    final secondaryTextColor = isDarkMode
        ? theme.colorScheme.onBackground.withOpacity(0.7)
        : Colors.black54;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(context, textColor, secondaryTextColor),
          const SizedBox(height: 32),
          _buildStatHeader(context, theme.colorScheme.primary),
          const SizedBox(height: 16),
          _buildStatisticsCard(cardColor, textColor, secondaryTextColor),
          const SizedBox(height: 32),
          _buildCategoryHeader(context, textColor),
          const SizedBox(height: 12),
          if (_categories.isNotEmpty)
            _buildCategorySelector(textColor, secondaryTextColor),
          const SizedBox(height: 16),
          if (_selectedCategoryId != null)
            _buildBooksByCategoryList(cardColor, textColor, secondaryTextColor),
        ],
      ).animate().fadeIn().slideY(begin: 0.1, curve: Curves.easeOut),
    );
  }

  Widget _buildGreeting(BuildContext context, Color textColor, Color secondaryTextColor) {
    return Row(
      children: [
        Hero(
          tag: 'member-avatar-$memberName',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: (photoUrl != null && photoUrl!.isNotEmpty)
                  ? Image.network(
                      _getAvatarUrl(photoUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(context),
                    )
                  : _buildPlaceholderAvatar(context),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, $memberName 👋',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2),
              const SizedBox(height: 4),
              Text(
                'Selamat datang di Perpustakaan!',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3),
            ],
          ),
        ),
      ],
    );
  }

  String _getAvatarUrl(String avatar) {
    if (avatar.isEmpty) return '';
    return avatar.startsWith('http')
        ? avatar
        : 'http://localhost:8000/storage/${avatar.replaceFirst(RegExp(r'^/'), '')}';
  }

  Widget _buildPlaceholderAvatar(BuildContext context) {
    return Container(
      width: _avatarRadius * 2,
      height: _avatarRadius * 2,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: _avatarRadius,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildStatHeader(BuildContext context, Color primaryColor) {
    return Text(
      '📊 Statistik Hari Ini',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1);
  }

  Widget _buildStatisticsCard(Color cardColor, Color textColor, Color secondaryTextColor) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(cardColor);
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildErrorCard('Gagal memuat statistik', cardColor, textColor);
        }

        final stats = snapshot.data!;
        return Card(
          color: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statItem(
                        Icons.library_books,
                        'Total Buku',
                        stats['book'] ?? 0,
                        Colors.blue,
                        secondaryTextColor,
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statItem(
                        Icons.person,
                        'Total Anggota',
                        stats['member'] ?? 0,
                        Colors.teal,
                        secondaryTextColor,
                      ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statItem(
                        Icons.book_online,
                        'Dipinjam',
                        stats['loan'] ?? 0,
                        Colors.orange,
                        secondaryTextColor,
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statItem(
                        Icons.assignment_turned_in,
                        'Dikembalikan',
                        stats['return'] ?? 0,
                        Colors.green,
                        secondaryTextColor,
                      ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 350.ms).scaleXY(begin: 0.95);
      },
    );
  }

  Widget _buildCategoryHeader(BuildContext context, Color textColor) {
    return Text(
      '📚 Buku Berdasarkan Kategori',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1);
  }

  Widget _buildCategorySelector(Color textColor, Color secondaryTextColor) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category['id'] == _selectedCategoryId;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                setState(() {
                  _selectedCategoryId = category['id'];
                  _booksByCategoryFuture = apiService.getBooksByCategory(_selectedCategoryId!);
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  category['name'] ?? '-',
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooksByCategoryList(Color cardColor, Color textColor, Color secondaryTextColor) {
    if (_selectedCategoryId == null) {
      return const SizedBox();
    }
    return FutureBuilder<List<dynamic>>(
      future: _booksByCategoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingList(cardColor, textColor);
        }
        if (snapshot.hasError) {
          return _buildErrorCard(
            'Gagal memuat buku',
            cardColor,
            textColor,
            onRetry: () {
              setState(() {
                _booksByCategoryFuture = apiService.getBooksByCategory(_selectedCategoryId!);
              });
            },
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(cardColor, textColor, onRefresh: () {
            setState(() {
              _booksByCategoryFuture = apiService.getBooksByCategory(_selectedCategoryId!);
            });
          });
        }
        final books = snapshot.data!;
        final filteredBooks = books.where((book) => book['category_id'] == _selectedCategoryId).toList();
        return Column(
          children: filteredBooks.take(5).map((book) {
            return _buildBookCard(
              book,
              cardColor,
              textColor,
              secondaryTextColor,
            ).animate().fadeIn(delay: (700 + (filteredBooks.indexOf(book) * 100)).ms);
          }).toList(),
        );
      },
    );
  }

  Widget _buildBookCard(
    Map<String, dynamic> book,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Konversi Map ke Book jika perlu
          final bookObj = Book.fromJson(book);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return BookDetailSheet(
                book: bookObj,
                scrollController: ScrollController(),
                memberId: null, // atau isi dengan memberId jika sudah login
                onBorrow: () {
                  // aksi pinjam buku
                },
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 80,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  child: book['cover'] != null && book['cover'].toString().isNotEmpty
                      ? Image.network(
                          _getCoverUrl(book['cover']),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              color: Theme.of(context).colorScheme.error,
                            );
                          },
                        )
                      : Icon(
                          Icons.menu_book_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'] ?? 'Tanpa Judul',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['author'] ?? '-',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: secondaryTextColor.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          book['category']?['name'] ?? '-',
                          style: TextStyle(fontSize: 12, color: secondaryTextColor.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCoverUrl(dynamic cover) {
    if (cover == null) return '';
    final coverStr = cover.toString();
    return coverStr.startsWith('http')
        ? coverStr
        : 'http://localhost:8000/storage/${coverStr.replaceFirst(RegExp(r'^/'), '')}';
  }

  Widget _statItem(
    IconData icon,
    String label,
    int value,
    Color color,
    Color secondaryTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(Color cardColor) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildLoadingList(Color cardColor, Color textColor) {
    return Column(
      children: List.generate(3, (index) {
        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: textColor.withOpacity(0.1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 16,
                        child: LinearProgressIndicator(
                          color: textColor.withOpacity(0.2),
                          backgroundColor: textColor.withOpacity(0.05),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 12,
                        child: LinearProgressIndicator(
                          color: textColor.withOpacity(0.2),
                          backgroundColor: textColor.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(String message, Color cardColor, Color textColor, {VoidCallback? onRetry}) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
            if (onRetry != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRetry,
                tooltip: 'Coba Lagi',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color cardColor, Color textColor, {VoidCallback? onRefresh}) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.menu_book,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada buku pada kategori ini',
              style: TextStyle(
                color: textColor.withOpacity(0.5),
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}