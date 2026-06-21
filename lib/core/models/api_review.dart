class ReviewModel {
  final int id;
  final int userId;
  final String? userName;
  final int productId;
  final int rating;
  final String? review;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.productId,
    required this.rating,
    this.review,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'],
      productId: json['product_id'] ?? 0,
      rating: json['rating'] ?? 5,
      review: json['review'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
