import 'package:flutter/material.dart';

class DendaScreen extends StatelessWidget {
  const DendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Denda')),
      body: const Center(
        child: Text('Belum ada denda aktif saat ini.'),
      ),
    );
  }
}
