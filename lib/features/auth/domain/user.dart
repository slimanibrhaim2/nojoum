enum UserRole{
  forecaster,
  publicUser;

  static UserRole fromString(String? value){
    switch(value){
      case('forecaster'):
        return UserRole.forecaster;
      case('public'):
        return UserRole.publicUser;
      default:
        return UserRole.publicUser;
    }
  }
}

class User {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? imageUrl;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.imageUrl,
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