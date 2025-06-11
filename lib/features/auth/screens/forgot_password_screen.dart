import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  int _step = 0; // 0: email, 1: new password
  bool _loading = false;
  String? _email;
  String? _token;
  String? _error;

  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<void> _sendResetLink() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Accept': 'application/json'},
        body: {'email': _emailController.text.trim()},
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _step = 1;
          _email = _emailController.text.trim();
          _token = data['acces_token'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link reset telah dikirim ke email $_email')),
        );
      } else {
        setState(() {
          _error = data['message'] ?? 'Terjadi kesalahan (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal mengirim permintaan. Cek koneksi Anda. ($e)';
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _error = 'Konfirmasi password tidak sama';
        _loading = false;
      });
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/new-password'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': _email ?? '',
          'token': _token ?? '',
          'password': _passwordController.text,
          'password_confirmation': _confirmController.text,
        },
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil direset!')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _error = data['message'] ?? 'Gagal reset password';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal mengirim permintaan. Cek koneksi Anda.';
      });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedSwitcher(
          duration: 400.ms,
          child: _step == 0 ? _buildEmailStep() : _buildNewPasswordStep(),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset, size: 80, color: Color(0xFF4E54C8))
            .animate()
            .shake(duration: 1000.ms),
        const SizedBox(height: 24),
        const Text(
          'Masukkan email Anda untuk menerima link reset password',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            errorText: _error,
          ),
          keyboardType: TextInputType.emailAddress,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () {
                  if (_emailController.text.trim().isEmpty) return;
                  _sendResetLink();
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF4E54C8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('KIRIM LINK RESET')
                  .animate()
                  .fadeIn(delay: 300.ms),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      key: const ValueKey('newpass-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.password_rounded, size: 80, color: Color(0xFF4E54C8))
            .animate()
            .fadeIn(),
        const SizedBox(height: 24),
        const Text(
          'Buat password baru untuk akun Anda',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password Baru',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            errorText: _error,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Konfirmasi Password',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () {
                  if (_passwordController.text.isEmpty ||
                      _confirmController.text.isEmpty) {
                    return;
                  }
                  _resetPassword();
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF4E54C8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('RESET PASSWORD')
                  .animate()
                  .fadeIn(delay: 300.ms),
        ),
      ],
    );
  }
}