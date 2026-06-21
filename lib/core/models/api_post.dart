class PostModel {
  final int id;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final String? content;
  final String? image;
  final String? styleTags;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime? createdAt;

  PostModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    this.content,
    this.image,
    this.styleTags,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user']?['name'],
      userAvatar: json['user']?['avatar'],
      content: json['content'],
      image: json['image'],
      styleTags: json['style_tags'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
