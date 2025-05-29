import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link reset telah dikirim ke email Anda')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF4E54C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('KIRIM LINK RESET')
                  .animate()
                  .fadeIn(delay: 300.ms),
            ),
          ],
        ),
      ),
    );
  }
}