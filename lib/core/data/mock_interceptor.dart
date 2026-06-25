import 'package:dio/dio.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import 'mock_data_source.dart';

class MockInterceptor extends Interceptor {
  final MockDataSource _mock = MockDataSource();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_mock.isInitialized) {
      try {
        await _mock.initialize();
      } catch (_) {
        handler.next(options);
        return;
      }
    }

    if (ApiClient.apiMode == ApiMode.fallback) {
      handler.next(options);
      return;
    }

    final response = _tryResolve(options);
    if (response != null) {
      handler.resolve(Response(
        requestOptions: options,
        data: response,
        statusCode: 200,
      ));
      return;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (ApiClient.apiMode == ApiMode.fallback && _isConnectionError(err)) {
      if (!_mock.isInitialized) {
        try {
          await _mock.initialize();
        } catch (_) {
          handler.next(err);
          return;
        }
      }

      final response = _tryResolve(err.requestOptions);
      if (response != null) {
        handler.resolve(Response(
          requestOptions: err.requestOptions,
          data: response,
          statusCode: 200,
        ));
        return;
      }
    }

    handler.next(err);
  }

  bool _isConnectionError(DioException error) {
    final type = error.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.connectionError) {
      return true;
    }
    if (type == DioExceptionType.badResponse) {
      final code = error.response?.statusCode;
      return code == null || code >= 500;
    }
    return error.response?.statusCode == null;
  }

  Map<String, dynamic>? _tryResolve(RequestOptions options) {
    final uri = options.uri.toString();
    final method = options.method.toUpperCase();
    final path = uri.replaceAll('http://localhost:8000/api', '');
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return null;

    try {
      return _resolveResponse(method, segments, options);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _resolveResponse(String method, List<String> segments, [RequestOptions? options]) {
    if (segments.isEmpty) return null;

    // Auth routes
    if (segments[0] == 'auth') {
      if (segments.length == 1) {
        if (method == 'GET') return _mock.getAuthProfileResponse();
        if (method == 'PUT') return _mock.getAuthUpdateProfileResponse();
      }
      if (segments.length == 2) {
        if (segments[1] == 'login') return _mock.getAuthLoginResponse();
        if (segments[1] == 'register') return _mock.getAuthRegisterResponse();
        if (segments[1] == 'logout') return _mock.getAuthLogoutResponse();
        if (segments[1] == 'avatar') {
          if (method == 'POST') return _mock.getAuthUploadAvatarResponse();
          if (method == 'DELETE') return _mock.getAuthDeleteAvatarResponse();
        }
      }
    }

    // Categories
    if (segments[0] == 'categories' && segments.length == 1 && method == 'GET') {
      return _mock.getCategoriesResponse();
    }

    // Products
    if (segments[0] == 'products') {
      if (segments.length == 1) {
        if (method == 'GET') {
          final qp = options?.queryParameters ?? {};
          return _mock.getProductsResponse(
            search: qp['search']?.toString(),
            category: qp['category']?.toString(),
            sort: qp['sort']?.toString(),
            minPrice: qp['min_price']?.toString() != null
                ? double.tryParse(qp['min_price'].toString())
                : null,
            maxPrice: qp['max_price']?.toString() != null
                ? double.tryParse(qp['max_price'].toString())
                : null,
          );
        }
      } else if (segments.length == 2) {
        if (segments[1] == 'featured') return _mock.getFeaturedProductsResponse();
        if (segments[1] == 'trending') return _mock.getTrendingProductsResponse();
        if (method == 'GET') return _mock.getProductBySlugResponse(segments[1]);
      } else if (segments.length == 3 && segments[2] == 'reviews') {
        final productId = int.tryParse(segments[1]) ?? 0;
        if (method == 'GET') return _mock.getReviewsResponse(productId);
        if (method == 'POST') return _mock.createReviewResponse();
      } else if (segments.length == 3 && segments[2] == 'stylist') {
        return _mock.getStylistResponse();
      }
    }

    // Reviews standalone
    if (segments[0] == 'reviews' && segments.length == 2) {
      if (method == 'PUT') return _mock.updateReviewResponse();
      if (method == 'DELETE') return _mock.deleteReviewResponse();
    }

    // Cart
    if (segments[0] == 'cart') {
      if (segments.length == 1) {
        if (method == 'GET') return _mock.getCartResponse();
        if (method == 'POST') return _mock.addToCartResponse(productId: 0);
      } else if (segments.length == 2) {
        final id = int.tryParse(segments[1]) ?? 0;
        if (method == 'PUT') return _mock.updateCartItemResponse(id, 1);
        if (method == 'DELETE') return _mock.removeFromCartResponse(id);
      }
    }

    // Wishlist
    if (segments[0] == 'wishlist') {
      if (segments.length == 1) {
        if (method == 'GET') return _mock.getWishlistResponse();
        if (method == 'POST') return _mock.addToWishlistResponse();
      } else if (segments.length == 2 && method == 'DELETE') {
        return _mock.removeFromWishlistResponse();
      }
    }

    // Orders
    if (segments[0] == 'orders') {
      if (segments.length == 1) {
        if (method == 'GET') return _mock.getOrdersResponse();
        if (method == 'POST') return _mock.placeOrderResponse();
      } else if (segments.length == 2 && method == 'GET') {
        final id = int.tryParse(segments[1]) ?? 0;
        return _mock.getOrderResponse(id);
      }
    }

    // Addresses
    if (segments[0] == 'addresses') {
      if (segments.length == 1) {
        if (method == 'GET') return _mock.getAddressesResponse();
        if (method == 'POST') return _mock.createAddressResponse();
      } else if (segments.length == 2) {
        if (method == 'PUT') return _mock.updateAddressResponse();
        if (method == 'DELETE') return _mock.deleteAddressResponse();
      } else if (segments.length == 3 && segments[2] == 'default') {
        return _mock.setDefaultAddressResponse();
      }
    }

    // Notifications
    if (segments[0] == 'notifications') {
      if (segments.length == 1 && method == 'GET') return _mock.getNotificationsResponse();
      if (segments.length == 2) {
        if (segments[1] == 'unread-count') return _mock.getUnreadCountResponse();
        if (segments[1] == 'read-all') return _mock.markAllAsReadResponse();
      }
      if (segments.length == 3 && segments[2] == 'read') return _mock.markAsReadResponse();
      if (segments.length == 2 && method == 'DELETE') return _mock.deleteNotificationResponse();
    }

    // Payments
    if (segments[0] == 'payments') {
      if (segments.length == 2 && segments[1] == 'history') return _mock.getPaymentHistoryResponse();
      if (segments.length == 2 && segments[1] == 'create') return _mock.createPaymentResponse();
      if (segments.length == 3 && segments[2] == 'verify') return _mock.verifyPaymentResponse();
    }

    // Social / Feed
    if (segments[0] == 'feed' && method == 'GET') return _mock.getFeedResponse();
    if (segments[0] == 'posts') {
      if (segments.length == 1) {
        if (method == 'GET') return _mock.getFeedResponse();
        if (method == 'POST') return _mock.createPostResponse();
      } else if (segments.length == 2 && method == 'DELETE') {
        return _mock.deletePostResponse();
      } else if (segments.length == 3 && segments[2] == 'like') {
        return _mock.toggleLikeResponse();
      } else if (segments.length == 3 && segments[2] == 'comment') {
        return _mock.addCommentResponse();
      }
    }
    if (segments[0] == 'users' && segments.length == 3 && segments[2] == 'follow') {
      return _mock.toggleFollowResponse();
    }

    // AI
    if (segments[0] == 'ai' && segments.length >= 2 && segments[1] == 'size-recommendation') {
      return _mock.getSizeRecommendationResponse();
    }

    // Admin - return empty fallback data
    if (segments[0] == 'admin') {
      return {'data': {'stats': {}, 'recent_orders': [], 'top_products': []}, 'message': 'Admin data unavailable in mock mode'};
    }

    return null;
  }
}
