class Book {
  final int id;
  final String title;
  final String author;
  final String? publisher;
  final String? isbn;
  final int? publicationYear;
  final int? stock;
  final String? description;
  final Map<String, dynamic>? category;
  final String? coverPath;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.publisher,
    this.isbn,
    this.publicationYear,
    this.stock,
    this.description,
    this.category,
    this.coverPath,
  });

    factory Book.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
  
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      publisher: json['publisher'],
      isbn: json['isbn'],
      publicationYear: parseInt(json['publication_year']),
      stock: parseInt(json['stock']),
      category: json['category'],
      coverPath: json['cover'] ?? json['cover_url'] ?? json['cover_image'],
    );
  }

  String? get coverUrl {
    if (coverPath == null || coverPath!.isEmpty) return null;
    final path = coverPath!.replaceFirst(RegExp(r'^/'), '');
    return 'http://localhost:8000/storage/$path';
  }
}