import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/member.dart';
import '../../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Member member;

  const EditProfileScreen({
    super.key,
    required this.member,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _phoneController = TextEditingController(text: widget.member.phone);
    _addressController = TextEditingController(text: widget.member.address);
    _emailController = TextEditingController(text: widget.member.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        // Ensure name doesn't exceed 15 characters
        final name = _nameController.text.length > 15
            ? _nameController.text.substring(0, 15)
            : _nameController.text;

        final member = Member(
          id: widget.member.id,
          name: name,
          memberId: widget.member.memberId,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          password: null,
          avatar: widget.member.avatar,
          createdAt: widget.member.createdAt,
          updatedAt: DateTime.now(),
        );

        final updatedMember = await ApiService().updateProfile(member);

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('member_id', updatedMember.memberId);
        await prefs.setString('name', updatedMember.name);
        await prefs.setString('phone', updatedMember.phone);
        await prefs.setString('address', updatedMember.address);
        await prefs.setString('avatar', updatedMember.avatar);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal update profil: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int? maxLength,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4E54C8)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          counterText: '', // Hide default counter text
          hintText: label == 'Nama Lengkap' ? 'Maksimal 15 karakter' : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4E54C8),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _loading ? null : _saveProfile,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'SIMPAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Pribadi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E54C8),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                label: 'ID Member',
                controller: TextEditingController(text: widget.member.memberId),
                readOnly: true,
              ),
              
              _buildTextField(
                label: 'Nama Lengkap',
                controller: _nameController,
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.length > 15) {
                    return 'Nama maksimal 15 karakter';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                label: 'Nomor Telepon',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                label: 'Alamat',
                controller: _addressController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}