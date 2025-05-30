import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode, Errors: $errors)';
}

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  String? token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  Future<void> setToken(String newToken) async {
    token = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
  }

  Future<void> clearToken() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('name');
    await prefs.remove('member_id');
    await prefs.remove('avatar');
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getMembers() async {
    try {
      await _loadToken(); // pastikan token dimuat
      final response = await http.get(
        Uri.parse('$baseUrl/members'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data; // langsung return list
        } else {
          throw Exception('Unexpected data format: not a list');
        }
      } else {
        throw Exception('Failed to fetch members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching members: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint('Failed to fetch profile: ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>> getBooks() async {
    try {
      await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/books'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data']['data'] ?? [];
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<List<dynamic>> getBooksByCategory(int categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/books?category_id=$categoryId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<List<dynamic>> getFavoriteBooks(String memberId) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/recomendation/$memberId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return data['data'] ?? [];
      } else {
        throw Exception('API error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load favorite books: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getLatestBooks() async {
    await _loadToken(); // Pastikan token dimuat
    final url = Uri.parse('$baseUrl/books/latest');

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      if (kDebugMode) {
        print('Request URL: $url');
        print('Request Headers: ${_headers()}');
        print('Raw API response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Gagal memuat buku terbaru: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching latest books: $e');
      }
      throw Exception('Error fetching latest books: $e');
    }
  }

  Future<List<dynamic>> getLoans() async {
    await _loadToken(); // Pastikan token dimuat
    final url = Uri.parse('$baseUrl/getBorrowing');

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      if (kDebugMode) {
        print('Request URL: $url');
        print('Request Headers: ${_headers()}');
        print('Raw API response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Gagal memuat daftar peminjaman: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching loans: $e');
      }
      throw Exception('Error fetching loans: $e');
    }
  }

  Future<List<dynamic>> getBorrowingLoans() async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/getBorrowing');

    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Gagal memuat daftar peminjaman: ${response.body}');
    }
  }

  Future<List<dynamic>> getReturnableLoans() async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/getLoan');

    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); 
      return data['data'] ?? [];
    } else {
      throw Exception('Gagal memuat daftar pengembalian: ${response.body}');
    }
  }

  Future<List<dynamic>> getReturnedLoans() async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/getReturned'); // Pastikan endpoint ini ada di backend

    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Gagal memuat riwayat pengembalian: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/statistics'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'book': data['book'] ?? 0,
          'member': data['member'] ?? 0,
          'loan': data['loan'] ?? 0,
          'return': data['return'] ?? 0,
        };
      } else {
        if (kDebugMode) {
          print('Gagal mengambil statistik: ${response.statusCode}');
        }
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat mengambil statistik: $e');
      }
      return {};
    }
  }

  Future<void> borrowBook(int bookId, int memberId) async {
    await _loadToken(); // Pastikan token dimuat
    final url = Uri.parse('$baseUrl/borrowings');

    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          'book_id': bookId,
          'member_id': memberId,
          'borrow_date': DateTime.now().toIso8601String(),
        }),
      );

      if (kDebugMode) {
        print('Request URL: $url');
        print('Request Headers: ${_headers()}');
        print('Request Body: ${jsonEncode({
              'book_id': bookId,
              'member_id': memberId,
              'borrow_date': DateTime.now().toIso8601String(),
            })}');
        print('Raw API response: ${response.body}');
      }

      if (response.statusCode != 200) {
        throw Exception('Gagal meminjam buku: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error borrowing book: $e');
      }
      throw Exception('Error borrowing book: $e');
    }
  }

  Future<Map<String, dynamic>> returnBook(int loanId) async {
    await _loadToken(); // Pastikan token dimuat
    final url = Uri.parse('$baseUrl/returns/$loanId');

    try {
      final response = await http.put(
        url,
        headers: _headers(),
      );

      if (kDebugMode) {
        print('Request URL: $url');
        print('Request Headers: ${_headers()}');
        print('Raw API response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body); // success response dari backend
      } else {
        return {
          'success': false,
          'message': 'Gagal mengembalikan buku: ${response.body}'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error returning book: $e');
      }
      return {
        'success': false,
        'message': 'Error returning book: $e',
      };
    }
  }

  Future<List<dynamic>> getReturns() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/returns'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load returns: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createLoan(String memberId, int bookId) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/loansBook');
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({'member_id': memberId, 'book_id': bookId}),
      );

      if (kDebugMode) {
        print(
          'Loan API Response: ${response.statusCode} - ${response.body}');
      } // Add logging

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? 'Gagal membuat peminjaman');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in createLoan: $e');
      } // Add error logging
      throw Exception('Terjadi kesalahan saat memproses peminjaman');
    }
  }

  Future<void> createReturn(Map<String, dynamic> returnData) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/returns'),
      headers: _headers(),
      body: json.encode(returnData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create return: ${response.body}');
    }
  }

  Future<List<dynamic>> getCategories() async {
    await _loadToken(); // Pastikan token dimuat
    final url = Uri.parse('$baseUrl/categories');

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      if (kDebugMode) {
        print('Request URL: $url');
        print('Request Headers: ${_headers()}');
        print('Raw API response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Gagal memuat kategori: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Gagal memuat profil: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    const String apiUrl = 'http://127.0.0.1:8000/api/login';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (kDebugMode) {
        print('Request payload: ${jsonEncode({
              'email': email,
              'password': password
            })}');
        print('Raw API response: ${response.body}');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['access_token'];
        final user = responseData['user'];
        final memberName = user['name'];
        final memberId = user['member_id'];

        if (token != null && token.isNotEmpty) {
          await setToken(token);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', memberName ?? ''); // Ganti dari 'member_name' ke 'name'
          await prefs.setString('member_id', memberId.toString());
          await prefs.setString('avatar', (user['avatar'] ?? '').toString());
          return {
            'success': true,
            'message': responseData['message'] ?? 'Login sukses',
            'data': {
              'access_token': token,
              'user': user,
            },
          };
        } else {
          return {
            'success': false,
            'message': 'Token tidak ditemukan dalam respons',
          };
        }
      } else {
        final error = responseData['message'] ?? 'Login gagal';
        return {'success': false, 'message': error};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Member> updateProfile(Member member, {String? newPassword}) async {
    await _loadToken();
    
    // Debug log to verify we're using the correct numeric ID
    debugPrint('Updating profile for ID: ${member.id}');

    final uri = Uri.parse('$baseUrl/update/profile/${member.id}');
    final request = http.MultipartRequest('POST', uri)
      ..fields['name'] = member.name
      ..fields['email'] = member.email
      ..fields['phone'] = member.phone
      ..fields['address'] = member.address
      ..fields['_method'] = 'PUT';

    // Handle avatar upload - platform independent
    if (member.avatar.isNotEmpty && !member.avatar.startsWith('http')) {
      if (kIsWeb) {
        // For web - send as base64 encoded string
        try {
          final bytes = await http.readBytes(Uri.parse(member.avatar));
          final base64Image = base64Encode(bytes);
          request.fields['avatar'] = base64Image;
        } catch (e) {
          debugPrint('Error encoding avatar: $e');
          request.fields['avatar'] = member.avatar;
        }
      } else {
        // For mobile/desktop
        try {
          final file = File(member.avatar);
          if (await file.exists()) {
            request.files.add(await http.MultipartFile.fromPath(
              'avatar',
              member.avatar,
              filename: member.avatar.split('/').last,
            ));
          }
        } catch (e) {
          debugPrint('Error uploading avatar file: $e');
          request.fields['avatar'] = member.avatar;
        }
      }
    }

    // Add password update if provided
    if (newPassword != null && newPassword.isNotEmpty) {
      request.fields['new_password'] = newPassword;
      request.fields['password_confirmation'] = newPassword;
    }

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    try {
      final response = await _sendRequest(request);
      debugPrint('Profile update response: ${response.toString()}');

      // Handle API response
      if (response.containsKey('data')) {
        if (response['data'] is Map) {
          return Member.fromJson(response['data']);
        }
        // If data is not a Map, return updated member with current data
        return member.copyWith(updatedAt: DateTime.now());
      }
      return Member.fromJson(response);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<bool> updatePassword(int memberId, String currentPassword, String newPassword) async {
    await _loadToken();
    
    // Basic validation
    if (newPassword.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/password/$memberId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'password_confirmation': newPassword,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          responseData['message'] ?? 
          'Failed to update password (Status: ${response.statusCode})'
        );
      }
    } catch (e) {
      debugPrint('Error in updatePassword: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      debugPrint('API Response: ${response.statusCode}');
      debugPrint('Response Body: $responseData');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData is Map) {
          return responseData as Map<String, dynamic>;
        }
        return {'status': 'success', 'data': responseData};
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Request failed',
          statusCode: response.statusCode,
          errors: responseData['errors'],
        );
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e) {
      throw Exception('Request failed: ${e.toString()}');
    }
  }

  Future<bool> deleteHistory() async {
    await _loadToken();
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getString('member_id');
    
    if (memberId == null) {
      throw Exception('Member ID not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/clearReturned'),
      headers: _headers(),
      body: jsonEncode({'member_id': memberId}),
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> reportLostBook(int bookId, int memberId) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/bookMissing/$bookId'),
      headers: _headers(),
      body: jsonEncode({'member_id': memberId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        json.decode(response.body)['message'] ?? 'Failed to report lost book'
      );
    }
  }

  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        await clearToken();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }
}
