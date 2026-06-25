import 'package:image_picker/image_picker.dart';
import '../models/api_address.dart';
import '../models/api_cart.dart';
import '../models/api_category.dart';
import '../models/api_notification.dart';
import '../models/api_order.dart';
import '../models/api_payment.dart';
import '../models/api_post.dart';
import '../models/api_product.dart';
import '../models/api_review.dart';
import '../models/api_user.dart';
import '../models/api_wishlist.dart';
import '../repositories/address_repository.dart';
import '../repositories/ai_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/review_repository.dart';
import '../repositories/social_repository.dart';
import '../repositories/wishlist_repository.dart';
import 'mock_data_source.dart';

class MockAuthRepository implements AuthRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<UserModel> login(String email, String password) async {
    final data = await _mock.initializeAndGet(() => _mock.getAuthLoginResponse());
    return UserModel.fromJson(data['user']);
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password, String? phone}) async {
    final data = await _mock.initializeAndGet(() => _mock.getAuthRegisterResponse());
    return UserModel.fromJson(data['user']);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel> profile() async {
    final data = await _mock.initializeAndGet(() => _mock.getAuthProfileResponse());
    return UserModel.fromJson(data['data']);
  }

  @override
  Future<UserModel> updateProfile({String? name, String? phone, String? avatar}) async {
    final data = await _mock.initializeAndGet(() => _mock.getAuthUpdateProfileResponse());
    return UserModel.fromJson(data['user']);
  }

  @override
  Future<UserModel> uploadAvatar(XFile file) async {
    final data = await _mock.initializeAndGet(() => _mock.getAuthUploadAvatarResponse());
    return UserModel.fromJson(data['user']);
  }

  @override
  Future<UserModel> deleteAvatar() async {
    final data = await _mock.initializeAndGet(() => _mock.getAuthDeleteAvatarResponse());
    return UserModel.fromJson(data['user']);
  }
}

class MockCategoryRepository implements CategoryRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<List<CategoryModel>> getCategories() async {
    final data = await _mock.initializeAndGet(() => _mock.getCategoriesResponse());
    return (data['data'] as List).map((e) => CategoryModel.fromJson(e)).toList();
  }
}

class MockProductRepository implements ProductRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<Map<String, dynamic>> getProducts({int page = 1, int perPage = 20, String? search, String? category, String? sort, double? minPrice, double? maxPrice}) async {
    final data = await _mock.initializeAndGet(() => _mock.getProductsResponse(search: search, category: category, sort: sort, minPrice: minPrice, maxPrice: maxPrice));
    return {
      'products': (data['data'] as List).map((e) => ProductModel.fromJson(e)).toList(),
      'meta': data['meta'],
    };
  }

  @override
  Future<List<ProductModel>> getFeatured() async {
    final data = await _mock.initializeAndGet(() => _mock.getFeaturedProductsResponse());
    return (data['data'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<List<ProductModel>> getTrending() async {
    final data = await _mock.initializeAndGet(() => _mock.getTrendingProductsResponse());
    return (data['data'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    final data = await _mock.initializeAndGet(() => _mock.getProductBySlugResponse(slug));
    return ProductModel.fromJson(data['data']);
  }
}

class MockCartRepository implements CartRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<({List<CartItemModel> items, CartMeta meta})> getCart() async {
    final data = await _mock.initializeAndGet(() => _mock.getCartResponse());
    return (
      items: (data['data'] as List).map((e) => CartItemModel.fromJson(e)).toList(),
      meta: CartMeta.fromJson(data['meta'] ?? {}),
    );
  }

  @override
  Future<CartItemModel> addToCart({required int productId, int quantity = 1, String? size, String? color}) async {
    final data = await _mock.initializeAndGet(() => _mock.addToCartResponse(productId: productId, quantity: quantity, size: size, color: color));
    return CartItemModel.fromJson(data['data']);
  }

  @override
  Future<CartItemModel> updateCartItem(int id, int quantity) async {
    final data = await _mock.initializeAndGet(() => _mock.updateCartItemResponse(id, quantity));
    return CartItemModel.fromJson(data['data']);
  }

  @override
  Future<void> removeFromCart(int id) async {
    await _mock.initializeAndGet(() => _mock.removeFromCartResponse(id));
  }
}

class MockWishlistRepository implements WishlistRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<List<WishlistModel>> getWishlist() async {
    final data = await _mock.initializeAndGet(() => _mock.getWishlistResponse());
    return (data['data'] as List).map((e) => WishlistModel.fromJson(e)).toList();
  }

  @override
  Future<WishlistModel> addToWishlist(int productId) async {
    final data = await _mock.initializeAndGet(() => _mock.addToWishlistResponse());
    return WishlistModel.fromJson(data['data']);
  }

  @override
  Future<void> removeFromWishlist(int productId) async {}
}

class MockOrderRepository implements OrderRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<OrderModel> placeOrder({required String shippingAddress, required String paymentMethod}) async {
    final data = await _mock.initializeAndGet(() => _mock.placeOrderResponse());
    return OrderModel.fromJson(data['data']);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final data = await _mock.initializeAndGet(() => _mock.getOrdersResponse());
    return (data['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  @override
  Future<OrderModel> getOrder(int id) async {
    final data = await _mock.initializeAndGet(() => _mock.getOrderResponse(id));
    return OrderModel.fromJson(data['data']);
  }
}

class MockAddressRepository implements AddressRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<List<AddressModel>> getAddresses() async {
    final data = await _mock.initializeAndGet(() => _mock.getAddressesResponse());
    return (data['data'] as List).map((e) => AddressModel.fromJson(e)).toList();
  }

  @override
  Future<AddressModel> createAddress({required String fullName, required String phone, required String country, required String city, required String district, required String street, String? postalCode, bool isDefault = false}) async {
    final data = await _mock.initializeAndGet(() => _mock.createAddressResponse());
    return AddressModel.fromJson(data['data']);
  }

  @override
  Future<AddressModel> updateAddress(int id, {String? fullName, String? phone, String? country, String? city, String? district, String? street, String? postalCode, bool? isDefault}) async {
    final data = await _mock.initializeAndGet(() => _mock.updateAddressResponse());
    return AddressModel.fromJson(data['data']);
  }

  @override
  Future<void> deleteAddress(int id) async {}

  @override
  Future<AddressModel> setDefault(int id) async {
    final data = await _mock.initializeAndGet(() => _mock.setDefaultAddressResponse());
    return AddressModel.fromJson(data['data']);
  }
}

class MockReviewRepository implements ReviewRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<({List<ReviewModel> reviews, double averageRating, int totalReviews})> getReviews(int productId, {int page = 1}) async {
    final data = await _mock.initializeAndGet(() => _mock.getReviewsResponse(productId));
    final List<ReviewModel> reviews = (data['data'] as List).map((e) => ReviewModel.fromJson(e)).toList();
    final meta = data['meta'] as Map<String, dynamic>;
    final double avg = (meta['average_rating'] ?? 0).toDouble();
    final int total = (meta['total_reviews'] ?? 0) as int;
    return (reviews: reviews, averageRating: avg, totalReviews: total);
  }

  @override
  Future<ReviewModel> createReview(int productId, {required int rating, String? review}) async {
    final data = await _mock.initializeAndGet(() => _mock.createReviewResponse());
    return ReviewModel.fromJson(data['data']);
  }

  @override
  Future<ReviewModel> updateReview(int reviewId, {required int rating, String? review}) async {
    final data = await _mock.initializeAndGet(() => _mock.updateReviewResponse());
    return ReviewModel.fromJson(data['data']);
  }

  @override
  Future<void> deleteReview(int reviewId) async {}
}

class MockNotificationRepository implements NotificationRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final data = await _mock.initializeAndGet(() => _mock.getNotificationsResponse());
    return (data['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final data = await _mock.initializeAndGet(() => _mock.getUnreadCountResponse());
    return data['data']?['count'] ?? 0;
  }

  @override
  Future<void> markAsRead(int id) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> delete(int id) async {}
}

class MockPaymentRepository implements PaymentRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<PaymentTransactionModel> createPayment({required int orderId, required String provider, required String paymentMethod}) async {
    final data = await _mock.initializeAndGet(() => _mock.createPaymentResponse());
    return PaymentTransactionModel.fromJson(data['data']);
  }

  @override
  Future<PaymentTransactionModel> verifyPayment(int transactionId, String status) async {
    final data = await _mock.initializeAndGet(() => _mock.verifyPaymentResponse());
    return PaymentTransactionModel.fromJson(data['data']);
  }

  @override
  Future<List<PaymentTransactionModel>> getPaymentHistory() async {
    final data = await _mock.initializeAndGet(() => _mock.getPaymentHistoryResponse());
    return (data['data'] as List).map((e) => PaymentTransactionModel.fromJson(e)).toList();
  }
}

class MockSocialRepository implements SocialRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<List<PostModel>> getFeed({int page = 1}) async {
    final data = await _mock.initializeAndGet(() => _mock.getFeedResponse());
    final feed = data['data'] as Map<String, dynamic>?;
    return ((feed?['data'] as List?) ?? []).map((e) => PostModel.fromJson(e)).toList();
  }

  @override
  Future<List<PostModel>> getPosts({int page = 1}) async {
    final data = await _mock.initializeAndGet(() => _mock.getFeedResponse());
    final posts = data['data'] as Map<String, dynamic>?;
    return ((posts?['data'] as List?) ?? []).map((e) => PostModel.fromJson(e)).toList();
  }

  @override
  Future<PostModel> createPost({String? content, String? styleTags}) async {
    final data = await _mock.initializeAndGet(() => _mock.createPostResponse());
    return PostModel.fromJson(data['data']);
  }

  @override
  Future<void> deletePost(int postId) async {}

  @override
  Future<Map<String, dynamic>> toggleLike(int postId) async {
    return {'message': 'Toggled'};
  }

  @override
  Future<void> addComment(int postId, String comment) async {}

  @override
  Future<void> toggleFollow(int userId) async {}

  @override
  Future<bool> isFollowing(int userId) async {
    return false;
  }
}

class MockAIRepository implements AIRepository {
  final MockDataSource _mock = MockDataSource();

  @override
  Future<Map<String, dynamic>> recommendSize({required int heightCm, required int weightKg, String? bodyType}) async {
    final data = await _mock.initializeAndGet(() => _mock.getSizeRecommendationResponse());
    return data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getOutfitRecommendation(int productId, String occasion) async {
    final data = await _mock.initializeAndGet(() => _mock.getStylistResponse());
    return data['data'] as Map<String, dynamic>;
  }
}
