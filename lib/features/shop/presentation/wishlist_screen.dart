import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_wishlist_provider.dart';
import '../../../core/providers/api_cart_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('Wishlist')),
      body: wishlistAsync.when(
        data: (wishlist) {
          if (wishlist.isEmpty) {
            return EmptyState(
              icon: FontAwesomeIcons.heart,
              title: 'Your wishlist is empty',
              subtitle: 'Save items you love for later',
              actionLabel: 'Browse Products',
              onAction: () => context.go('/shop'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlist.length,
            itemBuilder: (ctx, i) {
              final w = wishlist[i];
              final product = w.product;
              if (product == null) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => context.push('/product/${product.slug}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(width: 80, height: 100, color: AppTheme.black, child: const Center(child: FaIcon(FontAwesomeIcons.image, color: AppTheme.gray, size: 24))),
                          errorWidget: (ctx, url, err) => Container(width: 80, height: 100, color: AppTheme.black, child: const Center(child: FaIcon(FontAwesomeIcons.image, color: AppTheme.gray, size: 24))),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('\$${product.effectivePrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              ref.read(cartProvider.notifier).add(productId: product.id);
                              ref.read(wishlistProvider.notifier).remove(product.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('Moved to cart'), backgroundColor: AppTheme.gold, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              );
                            },
                            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.gold.withAlpha(50), borderRadius: BorderRadius.circular(10)), child: const FaIcon(FontAwesomeIcons.bagShopping, color: AppTheme.gold, size: 18)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => ref.read(wishlistProvider.notifier).remove(product.id),
                            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.redAccent.withAlpha(50), borderRadius: BorderRadius.circular(10)), child: const FaIcon(FontAwesomeIcons.trashCan, color: Colors.redAccent, size: 18)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
    );
  }
}
