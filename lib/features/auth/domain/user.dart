enum UserRole{
  forecaster,
  publicUser;

  static UserRole fromString(String? value) {
    final normalized = value?.toLowerCase() ?? '';
    if (normalized.contains('forecast')) return UserRole.forecaster;
    if (normalized.contains('public')) return UserRole.publicUser;
    return UserRole.publicUser;
  }
}

class User {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? imageUrl;
  final bool isOnboarded;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.imageUrl,
    this.isOnboarded = true,
  });

  factory User.fromJson(Map<String, dynamic> json)=>
      User(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String? ?? '', // for if we use a firebase it is not required
        role: UserRole.fromString(json['role'] as String),
        imageUrl: json['imageUrl'] as String?,
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'email': email,
        'fullName': fullName,
        'role': role.name,
        'imageUrl': imageUrl,
      };
}