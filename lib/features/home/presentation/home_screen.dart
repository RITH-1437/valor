import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/api_category_provider.dart';
import '../../../core/providers/api_product_provider.dart';
import '../../../core/models/api_product.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredProductsProvider);
    final trending = ref.watch(trendingProductsProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(trendingProductsProvider);
        },
        color: AppTheme.gold,
        backgroundColor: AppTheme.darkGray,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Welcome Back,', style: TextStyle(fontSize: 14, color: AppTheme.gray)),
                              const SizedBox(height: 4),
                              Text(
                                auth.user?.name ?? 'Guest',
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                              ),
                            ],
                          ),
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppTheme.darkGray,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.darkGray),
                            ),
                            child: const Center(
                              child: Icon(Icons.shopping_bag_outlined, color: AppTheme.gold, size: 28),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
                    const SizedBox(height: 16),
                    categories.when(
                      data: (cats) => SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cats.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (ctx, i) {
                            final cat = cats[i];
                            return GestureDetector(
                              onTap: () => context.push('/shop?category=${cat.slug}'),
                              child: Column(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppTheme.darkGray,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.darkGray),
                                    ),
                                    child: const Icon(Icons.checkroom, color: AppTheme.gold, size: 28),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(cat.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      loading: () => const SizedBox(height: 90, child: Center(child: CircularProgressIndicator(color: AppTheme.gold))),
                      error: (_, _) => const SizedBox(height: 90),
                    ),
                  ],
                ),
              ),
            ),

            // Featured
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: const Text('Featured Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            featured.when(
              data: (products) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ProductCard(product: products[i]),
                    childCount: products.length,
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.gold))),
              error: (_, _) => const SliverToBoxAdapter(child: Center(child: Text('Failed to load', style: TextStyle(color: AppTheme.gray)))),
            ),

            // Trending
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: const Text('Trending Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            trending.when(
              data: (products) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ProductCard(product: products[i]),
                    childCount: products.length,
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.gold))),
              error: (_, _) => const SliverToBoxAdapter(child: Center(child: Text('Failed to load', style: TextStyle(color: AppTheme.gray)))),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.slug}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(color: AppTheme.black, child: const Center(child: Icon(Icons.image, color: AppTheme.gray, size: 40))),
                  errorWidget: (ctx, url, err) => Container(color: AppTheme.black, child: const Center(child: Icon(Icons.broken_image, color: AppTheme.gray, size: 40))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.hasDiscount)
                        Text('\$${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppTheme.gray, decoration: TextDecoration.lineThrough)),
                      if (product.hasDiscount) const SizedBox(width: 6),
                      Text('\$${product.effectivePrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
