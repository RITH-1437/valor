import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_product_provider.dart';
import '../../../core/providers/api_category_provider.dart';
import '../../../core/providers/api_wishlist_provider.dart';
import '../../../core/models/api_product.dart';
import '../../../shared/widgets/empty_state.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? category;
  final String title;

  const ProductListScreen({super.key, this.category, this.title = 'Shop All'});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productFilterProvider.notifier).setCategory(widget.category);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final filter = ref.watch(productFilterProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => ref.read(productFilterProvider.notifier).setSearch(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: AppTheme.gray),
                prefixIcon: const Icon(Icons.search, color: AppTheme.gray),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.gray, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productFilterProvider.notifier).setSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 44,
            child: categories.when(
              data: (cats) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cats.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    final isActive = filter.category == null;
                    return GestureDetector(
                      onTap: () => ref.read(productFilterProvider.notifier).setCategory(null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.gold : AppTheme.darkGray,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(child: Text('All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? AppTheme.black : Colors.white))),
                      ),
                    );
                  }
                  final cat = cats[i - 1];
                  final isActive = filter.category == cat.slug;
                  return GestureDetector(
                    onTap: () => ref.read(productFilterProvider.notifier).setCategory(isActive ? null : cat.slug),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.gold : AppTheme.darkGray,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(child: Text(cat.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? AppTheme.black : Colors.white))),
                    ),
                  );
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // Sort chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildSortChip('Newest', 'newest', filter),
                const SizedBox(width: 8),
                _buildSortChip('Price ↑', 'price_asc', filter),
                const SizedBox(width: 8),
                _buildSortChip('Price ↓', 'price_desc', filter),
                if (filter.sort != null || filter.search != null || filter.category != null) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(productFilterProvider.notifier).reset();
                      _searchController.clear();
                    },
                    child: const Text('Clear', style: TextStyle(color: AppTheme.gold, fontSize: 13)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (data) {
                final products = data['products'] as List<ProductModel>;
                if (products.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No products found',
                    subtitle: 'Try adjusting your search or filters',
                    actionLabel: 'Clear Filters',
                    onAction: () {
                      ref.read(productFilterProvider.notifier).reset();
                      _searchController.clear();
                    },
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _ProductCard(product: products[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, dynamic filter) {
    final isActive = filter.sort == value;
    return GestureDetector(
      onTap: () => ref.read(productFilterProvider.notifier).setSort(isActive ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.gold : AppTheme.darkGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? AppTheme.black : Colors.white)),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.value?.any((w) => w.productId == product.id) ?? false;

    return GestureDetector(
      onTap: () => context.push('/product/${product.slug}'),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(color: AppTheme.black, child: const Center(child: Icon(Icons.image, color: AppTheme.gray, size: 40))),
                        errorWidget: (ctx, url, err) => Container(color: AppTheme.black, child: const Center(child: Icon(Icons.broken_image, color: AppTheme.gray, size: 40))),
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(6)),
                          child: Text('-${product.discountPercent}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.black)),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (isWishlisted) {
                            ref.read(wishlistProvider.notifier).remove(product.id);
                          } else {
                            ref.read(wishlistProvider.notifier).add(product.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppTheme.black, shape: BoxShape.circle),
                          child: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border, size: 18, color: isWishlisted ? AppTheme.gold : Colors.white70),
                        ),
                      ),
                    ),
                  ],
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
