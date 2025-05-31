import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final Color? backgroundColor;
  final BorderRadius borderRadius;

  const MemberAvatar({
    super.key,
    required this.photoUrl,
    this.size = 60,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  String _getAvatarUrl(String avatar) {
    if (avatar.isEmpty) return '';
    return avatar.startsWith('http')
        ? avatar
        : 'http://localhost:8000/storage/${avatar.replaceFirst(RegExp(r'^/'), '')}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: size,
        height: size,
        color: backgroundColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: (photoUrl != null && photoUrl!.isNotEmpty)
            ? Image.network(
                _getAvatarUrl(photoUrl!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(context),
              )
            : _buildPlaceholderAvatar(context),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(BuildContext context) {
    return Image.asset(
      'assets/images/profile_placeholder.png',
      fit: BoxFit.cover,
    );
  }
}