class ReviewModel {
  final String id;
  final UserModel user;
  final String content;
  final DateTime createdAt;
  final int rating;
  final String busId;

  ReviewModel({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.rating,
    required this.busId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      rating: json['rating'],
      busId: json['busId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'rating': rating,
        'busId': busId,
      };
}

class UserModel {
  final String id;
  final String name;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
      };
}
