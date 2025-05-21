// lib/models/loan.dart
import 'package:intl/intl.dart';

class Loan {
  final int id;
  final int bookId;
  final String bookTitle;
  final String borrowerName;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  
  Loan({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.borrowerName,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
  });
  
  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      bookId: json['book_id'],
      bookTitle: json['book_title'],
      borrowerName: json['borrower_name'],
      borrowDate: DateTime.parse(json['borrow_date']),
      dueDate: DateTime.parse(json['due_date']),
      returnDate: json['return_date'] != null ? DateTime.parse(json['return_date']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      'id': id,
      'book_id': bookId,
      'book_title': bookTitle,
      'borrower_name': borrowerName,
      'borrow_date': formatter.format(borrowDate),
      'due_date': formatter.format(dueDate),
      'return_date': returnDate != null ? formatter.format(returnDate!) : null,
    };
  }
  
  bool get isReturned => returnDate != null;
  
  bool get isOverdue {
    if (isReturned) return false;
    return DateTime.now().isAfter(dueDate);
  }
  
  String get status {
    if (isReturned) return 'Dikembalikan';
    if (isOverdue) return 'Terlambat';
    return 'Dipinjam';
  }
}