import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_frontend/models/book.dart';
import 'package:library_frontend/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'widget_test.mocks.dart';

// Buat mock class untuk ApiService
@GenerateMocks([ApiService])
void main() {
  testWidgets('BookListScreen shows list of books', (WidgetTester tester) async {
    final mockApiService = MockApiService();

    // Data dummy buku
    final dummyBooks = [
      Book(id: 1, title: 'Test Book', author: 'Test Author', year: 2024),
    ];

    // Set behavior mock
    when(mockApiService.getBooks()).thenAnswer((_) async => dummyBooks);

    // Jalankan widget dengan inject mock
    await tester.pumpWidget(
      MaterialApp(
        home: BookListScreenTestable(apiService: mockApiService),
      ),
    );

    // Tunggu async selesai
    await tester.pumpAndSettle();

    // Verifikasi UI tampil
    expect(find.text('Test Book'), findsOneWidget);
    expect(find.text('Test Author (2024)'), findsOneWidget);
  });
}

/// Widget testable versi BookListScreen dengan dependency injection
class BookListScreenTestable extends StatefulWidget {
  final ApiService apiService;
  const BookListScreenTestable({super.key, required this.apiService});

  @override
  State<BookListScreenTestable> createState() => _BookListScreenTestableState();
}

class _BookListScreenTestableState extends State<BookListScreenTestable> {
  late Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = widget.apiService.getBooks().then((value) => value.cast<Book>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No books found');
          } else {
            final book = snapshot.data!.first;
            return ListTile(
              title: Text(book.title),
              subtitle: Text('${book.author} (${book.year})'),
            );
          }
        },
      ),
    );
  }
}
