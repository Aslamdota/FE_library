import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  String? token;

  ApiService() {
    _init();
  }

  Future<void> _init() async {
    await _loadToken();
  }

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
    await prefs.remove('member_name');
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getStoredMemberName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('member_name');
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
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

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    await _loadToken();
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: _headers(),
      body: json.encode({
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal mengupdate profil: ${response.body}');
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/change-password'),
      headers: _headers(),
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal mengganti password: ${response.body}');
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

  Future<Map<String, dynamic>> updateMember({
    required int memberId,
    required String name,
    required String phone,
    required String address,
    String? password,
    String? avatarPath, // local file path
  }) async {
    final prefs = await SharedPreferences.getInstance();
    token ??= prefs.getString('token');

    var uri = Uri.parse('$baseUrl/members/$memberId');
    var request = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..fields['phone'] = phone
      ..fields['address'] = address
      ..fields['_method'] = 'PUT'; // Laravel resource update via POST

    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
    }

    if (avatarPath != null && avatarPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatarPath));
    }

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['message'] ?? 'Gagal update profil');
    }
  }

    Future<bool> deleteHistory() async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/clearReturned');
    final token = await getStoredToken();
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getString('member_id');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
      body: jsonEncode({
        'member_id': memberId,
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> reportLostBook(int bookId, int memberId) async {
    final url = Uri.parse('$baseUrl/bookMissing/$bookId');
    final token = await getStoredToken(); // gunakan getStoredToken() yang sudah ada

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // jika perlu
      },
      body: jsonEncode({
        'member_id': memberId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal melaporkan buku hilang');
    }
  }

  Future<bool> logout() async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      await clearToken();
      return true;
    } else {
      return false;
    }
  }
}
