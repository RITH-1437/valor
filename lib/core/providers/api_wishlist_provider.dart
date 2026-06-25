import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repositories.dart';
import '../models/api_wishlist.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import '../repositories/wishlist_repository.dart';
import 'auth_provider.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiWishlistRepository() : MockWishlistRepository();
});

class WishlistNotifier extends AsyncNotifier<List<WishlistModel>> {
  @override
  Future<List<WishlistModel>> build() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return [];
    return ref.read(wishlistRepositoryProvider).getWishlist();
  }

  Future<void> add(int productId) async {
    try {
      await ref.read(wishlistRepositoryProvider).addToWishlist(productId);
      ref.invalidateSelf();
    } catch (_) {}
  }

  Future<void> remove(int productId) async {
    try {
      await ref.read(wishlistRepositoryProvider).removeFromWishlist(productId);
      ref.invalidateSelf();
    } catch (_) {}
  }
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<WishlistModel>>(WishlistNotifier.new);
