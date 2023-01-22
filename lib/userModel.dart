class User {
  final String name;
  final String email;
  final String password;
  final Uri imageUri;

  User(
      {required this.name,
      required this.email,
      required this.password,
      required this.imageUri});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      imageUri: Uri.parse(json['imageUri']),
    );
  }
}
