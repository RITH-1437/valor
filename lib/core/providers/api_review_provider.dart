import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repositories.dart';
import '../models/api_review.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import '../repositories/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiReviewRepository() : MockReviewRepository();
});

class ReviewState {
  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalReviews;
  final bool isLoading;

  ReviewState({
    this.reviews = const [],
    this.averageRating = 0,
    this.totalReviews = 0,
    this.isLoading = false,
  });
}

class ReviewNotifier extends Notifier<ReviewState> {
  int _productId = 0;

  @override
  ReviewState build() => ReviewState();

  void load(int productId) async {
    _productId = productId;
    state = ReviewState(isLoading: true);
    try {
      final result = await ref.read(reviewRepositoryProvider).getReviews(productId);
      state = ReviewState(
        reviews: result.reviews,
        averageRating: result.averageRating,
        totalReviews: result.totalReviews,
      );
    } catch (_) {
      state = ReviewState();
    }
  }

  Future<void> add({required int rating, String? review}) async {
    try {
      await ref.read(reviewRepositoryProvider).createReview(_productId, rating: rating, review: review);
      load(_productId);
    } catch (_) {}
  }

  Future<void> update(int reviewId, {required int rating, String? review}) async {
    try {
      await ref.read(reviewRepositoryProvider).updateReview(reviewId, rating: rating, review: review);
      load(_productId);
    } catch (_) {}
  }

  Future<void> remove(int reviewId) async {
    try {
      await ref.read(reviewRepositoryProvider).deleteReview(reviewId);
      load(_productId);
    } catch (_) {}
  }
}

final reviewProvider = NotifierProvider<ReviewNotifier, ReviewState>(ReviewNotifier.new);
