import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repositories.dart';
import '../models/api_cart.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import '../repositories/cart_repository.dart';
import 'auth_provider.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiCartRepository() : MockCartRepository();
});

class CartState {
  final List<CartItemModel> items;
  final CartMeta? meta;

  CartState({this.items = const [], this.meta});
}

class CartNotifier extends AsyncNotifier<CartState> {
  @override
  Future<CartState> build() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return CartState();
    try {
      final result = await ref.read(cartRepositoryProvider).getCart();
      return CartState(items: result.items, meta: result.meta);
    } catch (_) {
      return CartState();
    }
  }

  Future<void> add({required int productId, int quantity = 1, String? size, String? color}) async {
    try {
      await ref.read(cartRepositoryProvider).addToCart(productId: productId, quantity: quantity, size: size, color: color);
      ref.invalidateSelf();
    } catch (_) {}
  }

  Future<void> updateQuantity(int id, int quantity) async {
    try {
      await ref.read(cartRepositoryProvider).updateCartItem(id, quantity);
      ref.invalidateSelf();
    } catch (_) {}
  }

  Future<void> remove(int id) async {
    try {
      await ref.read(cartRepositoryProvider).removeFromCart(id);
      ref.invalidateSelf();
    } catch (_) {}
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartState>(CartNotifier.new);
