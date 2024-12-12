class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? description;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.description,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final record = json['record'] ?? {};

    return User(
      id: record['id'] ?? '',
      username: record['username'] ?? '',
      email: record['email'] ?? '',
      avatar: record['avatar'].toString().isEmpty ? null : record['avatar'],
      description: record['description'].toString().isEmpty ? null : record['description'],
      token: json['token'] ?? '',
    );
  }
}