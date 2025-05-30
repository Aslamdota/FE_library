class Member {
  final int id;
  final String name;
  final String memberId;
  final String email;
  final String phone;
  final String address;
  final String? password;
  final String avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  Member({
    required this.id,
    required this.name,
    required this.memberId,
    required this.email,
    required this.phone,
    required this.address,
    this.password,
    required this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return Member(
      id: _parseInt(data['id']),
      name: data['name']?.toString() ?? 'Tidak diketahui',
      memberId: data['member_id']?.toString() ?? '',
      email: data['email']?.toString() ?? 'Tidak tersedia',
      phone: data['phone']?.toString() ?? 'Tidak tersedia',
      address: data['address']?.toString() ?? 'Tidak tersedia',
      password: data['password']?.toString(),
      avatar: data['avatar']?.toString() ?? '',
      createdAt: _parseDateTime(data['created_at']),
      updatedAt: _parseDateTime(data['updated_at']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'member_id': memberId,
      'email': email,
      'phone': phone,
      'address': address,
      if (password != null) 'password': password,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Member copyWith({
    int? id,
    String? name,
    String? memberId,
    String? email,
    String? phone,
    String? address,
    String? password,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      memberId: memberId ?? this.memberId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Member(id: $id, name: $name, memberId: $memberId, email: $email, '
        'phone: $phone, address: $address, avatar: $avatar, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}