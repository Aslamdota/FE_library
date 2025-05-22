class Book {
  final int id;
  final String title;
  final String author;
  final String? publisher;
  final String? isbn;
  final int? publicationYear;
  final int? stock;
  final Map<String, dynamic>? category;
  final String? coverUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.publisher,
    this.isbn,
    this.publicationYear,
    this.stock,
    this.category, required int year,
    this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      publisher: json['publisher'],
      isbn: json['isbn'],
      publicationYear: json['publication_year'],
      stock: json['stock'],
      category: json['category'], 
      year: json['publication_year'] ?? 0,
      coverUrl: json['cover'] ?? json['cover_url'],
    );
  }

  get year => null;
}
