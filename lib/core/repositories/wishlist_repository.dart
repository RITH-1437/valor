import '../models/api_wishlist.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

abstract class WishlistRepository {
  Future<List<WishlistModel>> getWishlist();
  Future<WishlistModel> addToWishlist(int productId);
  Future<void> removeFromWishlist(int productId);
}

class ApiWishlistRepository implements WishlistRepository {
  final _client = ApiClient().dio;

  @override
  Future<List<WishlistModel>> getWishlist() async {
    final response = await _client.get(ApiConstants.wishlist);
    final data = response.data['data'] as List;
    return data.map((e) => WishlistModel.fromJson(e)).toList();
  }

  @override
  Future<WishlistModel> addToWishlist(int productId) async {
    final response = await _client.post(ApiConstants.wishlist, data: {
      'product_id': productId,
    });
    return WishlistModel.fromJson(response.data['data']);
  }

  @override
  Future<void> removeFromWishlist(int productId) async {
    await _client.delete('${ApiConstants.wishlist}/$productId');
  }
}
