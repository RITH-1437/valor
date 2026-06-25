import '../models/api_cart.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

abstract class CartRepository {
  Future<({List<CartItemModel> items, CartMeta meta})> getCart();
  Future<CartItemModel> addToCart({required int productId, int quantity = 1, String? size, String? color});
  Future<CartItemModel> updateCartItem(int id, int quantity);
  Future<void> removeFromCart(int id);
}

class ApiCartRepository implements CartRepository {
  final _client = ApiClient().dio;

  @override
  Future<({List<CartItemModel> items, CartMeta meta})> getCart() async {
    final response = await _client.get(ApiConstants.cart);
    final data = response.data;
    return (
      items: (data['data'] as List).map((e) => CartItemModel.fromJson(e)).toList(),
      meta: CartMeta.fromJson(data['meta']),
    );
  }

  @override
  Future<CartItemModel> addToCart({
    required int productId,
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    final response = await _client.post(ApiConstants.cart, data: {
      'product_id': productId,
      'quantity': quantity,
      'selected_size': size,
      'selected_color': color,
    });
    return CartItemModel.fromJson(response.data['data']);
  }

  @override
  Future<CartItemModel> updateCartItem(int id, int quantity) async {
    final response = await _client.put('${ApiConstants.cart}/$id', data: {
      'quantity': quantity,
    });
    return CartItemModel.fromJson(response.data['data']);
  }

  @override
  Future<void> removeFromCart(int id) async {
    await _client.delete('${ApiConstants.cart}/$id');
  }
}
