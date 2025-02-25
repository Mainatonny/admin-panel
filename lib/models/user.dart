// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final int points;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.points,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      points: json['points'] ?? 0,
    );
  }
}
