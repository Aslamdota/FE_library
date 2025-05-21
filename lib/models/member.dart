class Member {
  final int id;
  final String name;
  final String email;
  final String photoUrl;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl
  });

  // Factory constructor untuk membuat objek Member dari JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tidak diketahui',
      email: json['email'] ?? 'Tidak tersedia',
      photoUrl: json['photo_url'],
    );
  }

  // Method untuk mengubah objek Member menjadi Map (opsional, jika dibutuhkan)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
    };
  }
}
