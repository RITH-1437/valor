import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_wishlist.dart';
import '../repositories/wishlist_repository.dart';
import 'auth_provider.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository();
});

class WishlistNotifier extends AsyncNotifier<List<WishlistModel>> {
  @override
  Future<List<WishlistModel>> build() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return [];
    return ref.read(wishlistRepositoryProvider).getWishlist();
  }

  Future<void> add(int productId) async {
    await ref.read(wishlistRepositoryProvider).addToWishlist(productId);
    ref.invalidateSelf();
  }

  Future<void> remove(int productId) async {
    await ref.read(wishlistRepositoryProvider).removeFromWishlist(productId);
    ref.invalidateSelf();
  }
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<WishlistModel>>(WishlistNotifier.new);
