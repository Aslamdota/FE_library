import 'package:flutter/material.dart';
import '../../../models/book.dart';

class BookDetailSheet extends StatefulWidget {
  final Book book;
  final ScrollController scrollController;
  final String? memberId;
  final VoidCallback onBorrow;

  const BookDetailSheet({
    super.key,
    required this.book,
    required this.scrollController,
    required this.memberId,
    required this.onBorrow,
  });

  @override
  State<BookDetailSheet> createState() => _BookDetailSheetState();
}

class _BookDetailSheetState extends State<BookDetailSheet> {
  bool _isLoading = false;

  void _handleBorrow() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300)); // animasi loading singkat
    widget.onBorrow();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final isLoggedIn = widget.memberId != null && widget.memberId!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.92,
        ),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Book cover with shadow and hero animation
              Center(
                child: Hero(
                  tag: 'book-cover-${widget.book.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: colorScheme.surfaceVariant,
                          width: 120,
                          height: 170,
                          child: widget.book.coverUrl != null && widget.book.coverUrl!.isNotEmpty
                              ? Image.network(
                                  widget.book.coverUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholderCover(colorScheme),
                                )
                              : _buildPlaceholderCover(colorScheme),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title and author
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.book.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.book.author,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Divider
              Divider(
                color: colorScheme.outline.withOpacity(0.15),
                thickness: 1,
                height: 28,
              ),

              // Book details
              _DetailRow(
                icon: Icons.business,
                label: 'Penerbit',
                value: widget.book.publisher ?? '-',
                colorScheme: colorScheme,
              ),
              _DetailRow(
                icon: Icons.qr_code_2,
                label: 'ISBN',
                value: widget.book.isbn ?? '-',
                colorScheme: colorScheme,
              ),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Tahun Terbit',
                value: widget.book.publicationYear?.toString() ?? '-',
                colorScheme: colorScheme,
              ),
              _DetailRow(
                icon: Icons.category,
                label: 'Kategori',
                value: widget.book.category?['name']?.toString() ?? '-',
                colorScheme: colorScheme,
              ),
              _DetailRow(
                icon: Icons.inventory_2,
                label: 'Stok Tersedia',
                value: widget.book.stock?.toString() ?? '0',
                colorScheme: colorScheme,
              ),

              if (widget.book.description != null && widget.book.description!.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Deskripsi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.book.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.85),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],

              const SizedBox(height: 32),

              // Borrow button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.shopping_bag_rounded, color: colorScheme.onPrimary),
                  onPressed: isLoggedIn && !_isLoading ? _handleBorrow : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 2,
                  ),
                  label: Text(
                    isLoggedIn
                        ? (_isLoading ? 'Memproses...' : 'Pinjam Buku')
                        : 'Pergi ke halaman Buku ☺',
                  ),
                ),
              ),

              SizedBox(height: mediaQuery.viewInsets.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary.withOpacity(0.85)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}