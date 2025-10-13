// lib/features/home/domain/models/user.dart
class User {
  final String id;
  final String firstName;
  final String? profilePictureUrl;

  User({required this.id, required this.firstName, this.profilePictureUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    final fullName = json['full_name'] as String? ?? '';
    final firstName = fullName.split(' ').first;

    return User(
      id: json['id'] as String,
      firstName: firstName,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }
}
