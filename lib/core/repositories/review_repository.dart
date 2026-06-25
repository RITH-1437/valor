import '../models/api_review.dart';
import '../network/api_client.dart';

abstract class ReviewRepository {
  Future<({List<ReviewModel> reviews, double averageRating, int totalReviews})> getReviews(int productId, {int page = 1});
  Future<ReviewModel> createReview(int productId, {required int rating, String? review});
  Future<ReviewModel> updateReview(int reviewId, {required int rating, String? review});
  Future<void> deleteReview(int reviewId);
}

class ApiReviewRepository implements ReviewRepository {
  final _client = ApiClient().dio;

  @override
  Future<({List<ReviewModel> reviews, double averageRating, int totalReviews})> getReviews(int productId, {int page = 1}) async {
    final response = await _client.get('/products/$productId/reviews', queryParameters: {'page': page});
    final data = response.data;
    final meta = data['meta'] as Map<String, dynamic>;
    final List<ReviewModel> reviews = (data['data'] as List).map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
    final double averageRating = (meta['average_rating'] ?? 0).toDouble();
    final int totalReviews = (meta['total_reviews'] ?? 0) as int;
    return (reviews: reviews, averageRating: averageRating, totalReviews: totalReviews);
  }

  @override
  Future<ReviewModel> createReview(int productId, {required int rating, String? review}) async {
    final response = await _client.post('/products/$productId/reviews', data: {
      'rating': rating,
      'review': review,
    });
    return ReviewModel.fromJson(response.data['data']);
  }

  @override
  Future<ReviewModel> updateReview(int reviewId, {required int rating, String? review}) async {
    final response = await _client.put('/reviews/$reviewId', data: {
      'rating': rating,
      'review': review,
    });
    return ReviewModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteReview(int reviewId) async {
    await _client.delete('/reviews/$reviewId');
  }
}
