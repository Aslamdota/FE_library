import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class LostReportScreen extends StatefulWidget {
  final int bookId;
  final int memberId;

  const LostReportScreen({
    super.key,
    required this.bookId,
    required this.memberId,
  });

  @override
  State<LostReportScreen> createState() => _LostReportScreenState();
}

class _LostReportScreenState extends State<LostReportScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isSubmitting = false;

  Future<void> _submitLostReport() async {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Alasan tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await apiService.reportLostBook(
        widget.bookId,
        widget.memberId,
      );

      if (result['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Laporan buku hilang berhasil dikirim'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(result['message'] ?? 'Gagal melapor');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Buku Hilang'),
        centerTitle: true,
        backgroundColor: Colors.red[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan Kehilangan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.book, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text('ID Buku: ${widget.bookId}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text('ID Anggota: ${widget.memberId}'),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _reasonController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Alasan Kehilangan',
                    hintText: 'Contoh: Buku hilang karena banjir...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.report_gmailerrorred),
                    label: Text(
                      _isSubmitting ? 'Mengirim...' : 'Laporkan Buku Hilang',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isSubmitting ? null : _submitLostReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
