import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/api_product.dart';
import '../models/api_category.dart';

class MockDataSource {
  static final MockDataSource _instance = MockDataSource._();
  factory MockDataSource() => _instance;
  MockDataSource._();

  bool _initialized = false;
  Map<String, dynamic> _authData = {};
  Map<String, dynamic> _categoriesData = const {'data': []};
  Map<String, dynamic> _productsData = const {'data': [], 'meta': {}};
  Map<String, dynamic> _reviewsData = const {'data': [], 'meta': {}};
  Map<String, dynamic> _cartData = {'data': [], 'meta': {'subtotal': 0.0, 'shipping': 0.0, 'tax': 0.0, 'total': 0.0, 'item_count': 0}};
  final List<Map<String, dynamic>> _cartItems = [];
  int _nextCartId = 1;
  Map<String, dynamic> _ordersData = const {'data': []};
  Map<String, dynamic> _wishlistData = const {'data': []};
  Map<String, dynamic> _addressesData = const {'data': []};
  Map<String, dynamic> _notificationsData = const {'data': []};
  Map<String, dynamic> _unreadCountData = const {'data': {'count': 0}};
  Map<String, dynamic> _paymentsData = const {'data': []};
  Map<String, dynamic> _feedData = const {'data': {'data': []}};
  Map<String, dynamic> _postsData = const {'data': {'data': []}};

  List<ProductModel>? _allProducts;
  List<CategoryModel>? _allCategories;
  final Map<String, ProductModel> _productsBySlug = {};

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await Future.wait([
      _load('auth.json').then((v) => _authData = v),
      _load('categories.json').then((v) => _categoriesData = v),
      _load('products.json').then((v) => _productsData = v),
      _load('reviews.json').then((v) => _reviewsData = v),
      _load('cart.json').then((v) => _cartData = v),
      _load('orders.json').then((v) => _ordersData = v),
      _load('wishlist.json').then((v) => _wishlistData = v),
      _load('addresses.json').then((v) => _addressesData = v),
      _load('notifications.json').then((v) => _notificationsData = v),
      _load('unread_count.json').then((v) => _unreadCountData = v),
      _load('payments.json').then((v) => _paymentsData = v),
      _load('feed.json').then((v) => _feedData = v),
      _load('posts.json').then((v) => _postsData = v),
    ]);

    _allProducts = ((_productsData['data'] ?? []) as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    _allCategories = ((_categoriesData['data'] ?? []) as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    for (final p in _allProducts!) {
      _productsBySlug[p.slug] = p;
    }
  }

  Future<Map<String, dynamic>> _load(String fileName) async {
    try {
      final string = await rootBundle.loadString('assets/mock/$fileName');
      return jsonDecode(string) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  bool get isInitialized => _initialized;

  Future<T> initializeAndGet<T>(T Function() callback) async {
    if (!_initialized) await initialize();
    return callback();
  }

  // ============================
  // Auth
  // ============================
  Map<String, dynamic> getAuthLoginResponse() => Map<String, dynamic>.from(_authData);
  Map<String, dynamic> getAuthRegisterResponse() => Map<String, dynamic>.from(_authData);
  Map<String, dynamic> getAuthProfileResponse() => {'data': _authData['user']};
  Map<String, dynamic> getAuthLogoutResponse() => {'message': 'Logged out successfully'};
  Map<String, dynamic> getAuthUpdateProfileResponse() => {'user': _authData['user']};
  Map<String, dynamic> getAuthUploadAvatarResponse() => {'user': _authData['user']};
  Map<String, dynamic> getAuthDeleteAvatarResponse() => {'user': {}};

  // ============================
  // Categories
  // ============================
  Map<String, dynamic> getCategoriesResponse() => _categoriesData;

  // ============================
  // Products
  // ============================
  Map<String, dynamic> getProductsResponse({String? search, String? category, String? sort, double? minPrice, double? maxPrice}) {
    var products = List<ProductModel>.from(_allProducts ?? []);

    if (category != null) {
      final cat = (_allCategories ?? []).where((c) => c.slug == category).firstOrNull;
      if (cat != null) products = products.where((p) => p.categoryId == cat.id).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      products = products.where((p) => p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q)).toList();
    }
    if (minPrice != null) products = products.where((p) => p.effectivePrice >= minPrice).toList();
    if (maxPrice != null) products = products.where((p) => p.effectivePrice <= maxPrice).toList();
    if (sort == 'price_asc') products.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
    if (sort == 'price_desc') products.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
    if (sort == 'newest') products.sort((a, b) => (b.createdAt ?? DateTime(2020)).compareTo(a.createdAt ?? DateTime(2020)));
    if (sort == 'popular') products.sort((a, b) => b.stock.compareTo(a.stock));

    return {
      'data': products.map((p) => p.toJson()).toList(),
      'meta': {'current_page': 1, 'last_page': 1, 'per_page': 20, 'total': products.length},
    };
  }

  Map<String, dynamic> getFeaturedProductsResponse() {
    final products = (_allProducts ?? []).where((p) => p.isFeatured).toList();
    return {'data': products.map((p) => p.toJson()).toList()};
  }

  Map<String, dynamic> getTrendingProductsResponse() {
    final products = (_allProducts ?? []).where((p) => p.isTrending).toList();
    return {'data': products.map((p) => p.toJson()).toList()};
  }

  Map<String, dynamic> getProductBySlugResponse(String slug) {
    final product = _productsBySlug[slug];
    if (product != null) return {'data': product.toJson()};
    return {'data': null, 'error': 'Product not found'};
  }

  ProductModel? getProductBySlug(String slug) => _productsBySlug[slug];
  ProductModel? getProductById(int id) => _allProducts?.where((p) => p.id == id).firstOrNull;

  // ============================
  // Cart (mutable in-memory state)
  // ============================
  Map<String, dynamic> getCartResponse() {
    _rebuildCartMeta();
    return {'data': List<Map<String, dynamic>>.from(_cartItems), 'meta': _cartMeta()};
  }

  Map<String, dynamic> addToCartResponse({required int productId, int quantity = 1, String? size, String? color}) {
    final existingIndex = _cartItems.indexWhere((item) =>
      item['product_id'] == productId &&
      item['selected_size'] == size &&
      item['selected_color'] == color
    );

    if (existingIndex != -1) {
      final existing = _cartItems[existingIndex];
      final newQty = (existing['quantity'] as int) + quantity;
      existing['quantity'] = newQty;
      existing['total_price'] = (existing['product']?['effective_price'] ?? 0.0) * newQty;
      return {'data': existing};
    }

    final product = getProductById(productId);
    final price = product?.effectivePrice ?? 0.0;
    final item = {
      'id': _nextCartId++,
      'product_id': productId,
      'quantity': quantity,
      'selected_size': size,
      'selected_color': color,
      'total_price': price * quantity,
      'created_at': DateTime.now().toIso8601String(),
      'product': product?.toJson(),
    };
    _cartItems.add(item);
    return {'data': item};
  }

  Map<String, dynamic> updateCartItemResponse(int id, int quantity) {
    final index = _cartItems.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      _cartItems[index]['quantity'] = quantity;
      final price = _cartItems[index]['product']?['effective_price'] ?? 0.0;
      _cartItems[index]['total_price'] = price * quantity;
      return {'data': _cartItems[index]};
    }
    return {'data': {}};
  }

  Map<String, dynamic> removeFromCartResponse(int id) {
    _cartItems.removeWhere((item) => item['id'] == id);
    return {'message': 'Removed from cart'};
  }

  Map<String, dynamic> clearCartResponse() {
    _cartItems.clear();
    return {'message': 'Cart cleared'};
  }

  void _rebuildCartMeta() {
    double subtotal = 0;
    int itemCount = 0;
    for (final item in _cartItems) {
      subtotal += (item['total_price'] ?? 0.0) as double;
      itemCount += (item['quantity'] ?? 1) as int;
    }
    final shipping = subtotal >= 150 ? 0.0 : 9.99;
    final tax = subtotal * 0.10;
    _cartData['meta'] = {
      'subtotal': double.parse(subtotal.toStringAsFixed(2)),
      'shipping': double.parse(shipping.toStringAsFixed(2)),
      'tax': double.parse(tax.toStringAsFixed(2)),
      'total': double.parse((subtotal + shipping + tax).toStringAsFixed(2)),
      'item_count': itemCount,
    };
  }

  Map<String, dynamic> _cartMeta() => _cartData['meta'];

  // ============================
  // Wishlist
  // ============================
  Map<String, dynamic> getWishlistResponse() => _wishlistData;
  Map<String, dynamic> addToWishlistResponse() => {'data': (_wishlistData['data'] as List).isNotEmpty ? (_wishlistData['data'] as List).first : {}};
  Map<String, dynamic> removeFromWishlistResponse() => {'message': 'Removed from wishlist'};

  // ============================
  // Orders
  // ============================
  Map<String, dynamic> getOrdersResponse() => _ordersData;
  Map<String, dynamic> placeOrderResponse() => {'data': (_ordersData['data'] as List).isNotEmpty ? (_ordersData['data'] as List).first : {}};
  Map<String, dynamic> getOrderResponse(int id) {
    final orders = _ordersData['data'] as List;
    final order = orders.where((o) => o['id'] == id).firstOrNull;
    return {'data': order ?? {}};
  }

  // ============================
  // Addresses
  // ============================
  Map<String, dynamic> getAddressesResponse() => _addressesData;
  Map<String, dynamic> createAddressResponse() => {'data': {}};
  Map<String, dynamic> updateAddressResponse() => {'data': {}};
  Map<String, dynamic> deleteAddressResponse() => {'message': 'Address deleted'};
  Map<String, dynamic> setDefaultAddressResponse() => {'data': {}};

  // ============================
  // Reviews
  // ============================
  Map<String, dynamic> getReviewsResponse(int productId) {
    final all = _reviewsData['data'] as List;
    final filtered = all.where((r) => r['product_id'] == productId).toList();
    final ratings = filtered.map((r) => (r['rating'] as num).toDouble()).toList();
    final avg = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    return {
      'data': filtered,
      'meta': {'average_rating': avg, 'total_reviews': filtered.length},
    };
  }
  Map<String, dynamic> createReviewResponse() => {'data': {'id': 99, 'user_id': 1, 'user_name': 'James Anderson', 'product_id': 1, 'rating': 5, 'review': '', 'created_at': '2026-06-22T00:00:00Z'}};
  Map<String, dynamic> updateReviewResponse() => {'data': {}};
  Map<String, dynamic> deleteReviewResponse() => {'message': 'Review deleted'};

  // ============================
  // Notifications
  // ============================
  Map<String, dynamic> getNotificationsResponse() => _notificationsData;
  Map<String, dynamic> getUnreadCountResponse() => _unreadCountData;
  Map<String, dynamic> markAsReadResponse() => {'message': 'Marked as read'};
  Map<String, dynamic> markAllAsReadResponse() => {'message': 'All marked as read'};
  Map<String, dynamic> deleteNotificationResponse() => {'message': 'Notification deleted'};

  // ============================
  // Payments
  // ============================
  Map<String, dynamic> getPaymentHistoryResponse() => _paymentsData;
  Map<String, dynamic> createPaymentResponse() => {'data': {}};
  Map<String, dynamic> verifyPaymentResponse() => {'data': {}};

  // ============================
  // AI
  // ============================
  Map<String, dynamic> getSizeRecommendationResponse() => {
    'data': {'recommended_size': 'L', 'tip': 'Based on your measurements, size L will provide the best fit. Consider going up a size if you prefer a relaxed look.'}
  };

  Map<String, dynamic> getStylistResponse() => {
    'data': {
      'outfit_name': 'Business Casual Excellence',
      'matching_colors': ['Navy', 'White', 'Brown', 'Gold'],
      'suggested_accessories': ['Leather Belt', 'Gold Watch', 'Brown Loafers'],
      'styling_tips': ['Pair with dark wash jeans for a balanced look', 'Roll sleeves for a relaxed yet polished vibe', 'Add a statement watch to elevate the outfit'],
    }
  };

  // ============================
  // Social
  // ============================
  Map<String, dynamic> getFeedResponse() {
    final feedItems = _feedData['data']?['data'] as List? ?? [];
    if (feedItems.isNotEmpty) return _feedData;
    final postItems = _postsData['data']?['data'] as List? ?? [];
    if (postItems.isNotEmpty) return _postsData;
    return _feedData;
  }
  Map<String, dynamic> createPostResponse() => {'data': {}};
  Map<String, dynamic> deletePostResponse() => {'message': 'Post deleted'};
  Map<String, dynamic> toggleLikeResponse() => {'message': 'Toggled'};
  Map<String, dynamic> addCommentResponse() => {'message': 'Comment added'};
  Map<String, dynamic> toggleFollowResponse() => {'message': 'Toggled'};
}

extension _ProductModelJson on ProductModel {
  Map<String, dynamic> toJson() => {
    'id': id, 'category_id': categoryId, 'name': name, 'slug': slug,
    'description': description, 'short_description': shortDescription,
    'price': price, 'discount_price': discountPrice, 'effective_price': effectivePrice,
    'has_discount': hasDiscount, 'discount_percent': discountPercent,
    'stock': stock, 'sku': sku, 'image': image,
    'is_featured': isFeatured, 'is_trending': isTrending, 'is_active': isActive,
    'images': images.map((i) => i.toJson()).toList(),
    'sizes': sizes.map((s) => s.toJson()).toList(),
    'colors': colors.map((c) => c.toJson()).toList(),
    'created_at': createdAt?.toIso8601String(),
  };
}

extension _ProductImageModelJson on ProductImageModel {
  Map<String, dynamic> toJson() => {'id': id, 'image': image, 'sort_order': sortOrder};
}

extension _ProductSizeModelJson on ProductSizeModel {
  Map<String, dynamic> toJson() => {'id': id, 'size': size};
}

extension _ProductColorModelJson on ProductColorModel {
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'hex_code': hexCode};
}
