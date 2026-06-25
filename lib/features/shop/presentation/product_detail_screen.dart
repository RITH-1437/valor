import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_product_provider.dart';
import '../../../core/providers/api_cart_provider.dart';
import '../../../core/providers/api_wishlist_provider.dart';
import '../../../core/providers/api_review_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/api_product.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  int _selectedRating = 5;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productBySlugProvider(widget.productId));
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: productAsync.when(
        data: (product) {
          _selectedSize ??= product.sizeLabels.isNotEmpty ? product.sizeLabels.first : null;
          _selectedColor ??= product.colorNames.isNotEmpty ? product.colorNames.first : null;
          final isWishlisted = wishlist.value?.any((w) => w.productId == product.id) ?? false;
          final images = product.imageUrls;

          // Load reviews when product loads
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(reviewProvider.notifier).load(product.id);
          });

          return CustomScrollView(
            slivers: [
              // Image Carousel
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: AppTheme.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  if (product.isFeatured)
                    Container(
                      margin: const EdgeInsets.only(top: 48, right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(6)),
                      child: const Text('FEATURED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.black, letterSpacing: 1)),
                    ),
                  if (product.isTrending)
                    Container(
                      margin: const EdgeInsets.only(top: 48, right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      child: const Text('TRENDING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.black, letterSpacing: 1)),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Main image with zoom
                      GestureDetector(
                        onDoubleTap: () => _showZoomDialog(context, images[_currentImageIndex]),
                        child: Hero(
                          tag: 'product_${product.id}',
                          child: PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (i) => setState(() => _currentImageIndex = i),
                            itemBuilder: (ctx, i) => CachedNetworkImage(
                              imageUrl: images[i],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => Container(color: AppTheme.darkGray, child: const Center(child: CircularProgressIndicator(color: AppTheme.gold))),
                              errorWidget: (ctx, url, err) => Container(color: AppTheme.darkGray, child: const Center(child: Icon(Icons.broken_image, color: AppTheme.gray, size: 40))),
                            ),
                          ),
                        ),
                      ),
                      // Image dots
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(color: _currentImageIndex == i ? AppTheme.gold : Colors.white38, borderRadius: BorderRadius.circular(4)),
                          )),
                        ),
                      ),
                      // Image counter
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                          child: Text('${_currentImageIndex + 1}/${images.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      // Wishlist button
                      Positioned(
                        top: 48,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            if (isWishlisted) {
                              ref.read(wishlistProvider.notifier).remove(product.id);
                            } else {
                              ref.read(wishlistProvider.notifier).add(product.id);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: AppTheme.black, shape: BoxShape.circle),
                            child: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border, color: isWishlisted ? AppTheme.gold : Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Row(
                        children: [
                          if (product.hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(6)),
                              child: Text('-${product.discountPercent}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.black)),
                            ),
                          if (product.stock <= 5 && product.stock > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.orange.withAlpha(50), borderRadius: BorderRadius.circular(6)),
                              child: Text('Only ${product.stock} left', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange)),
                            ),
                          ],
                          if (product.stock == 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.redAccent.withAlpha(50), borderRadius: BorderRadius.circular(6)),
                              child: const Text('Out of Stock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text(product.name, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(height: 12),

                      // Price
                      Row(
                        children: [
                          Text('\$${product.effectivePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w800)),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 12),
                            Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: AppTheme.gray, decoration: TextDecoration.lineThrough)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text('Description', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(product.description, style: const TextStyle(color: AppTheme.gray, fontSize: 14, height: 1.6)),
                      const SizedBox(height: 24),

                      // Size Selection
                      if (product.sizeLabels.isNotEmpty) ...[
                        Row(
                          children: [
                            const Text('Select Size', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            if (_selectedSize == null)
                              const Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: product.sizeLabels.map((size) {
                            final selected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = size),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                decoration: BoxDecoration(
                                  color: selected ? AppTheme.gold : AppTheme.darkGray,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: selected ? AppTheme.gold : const Color(0xFF374151), width: selected ? 2 : 1),
                                ),
                                child: Text(size, style: TextStyle(color: selected ? AppTheme.black : Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Color Selection
                      if (product.colorNames.isNotEmpty) ...[
                        Row(
                          children: [
                            const Text('Select Color', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            if (_selectedColor == null)
                              const Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                            if (_selectedColor != null) ...[
                              const SizedBox(width: 8),
                              Text(_selectedColor!, style: const TextStyle(color: AppTheme.gold, fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: product.colors.map((color) {
                            final selected = _selectedColor == color.name;
                            final hexColor = int.tryParse(color.hexCode.replaceFirst('#', '0xFF'), radix: 16) ?? 0xFF000000;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = color.name),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(hexColor),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: selected ? AppTheme.gold : Colors.white24, width: selected ? 3 : 1),
                                  boxShadow: selected ? [BoxShadow(color: AppTheme.gold.withAlpha(80), blurRadius: 8)] : null,
                                ),
                                child: selected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Quantity
                      const Text('Quantity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () { if (_quantity > 1) setState(() => _quantity--); },
                            child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.remove, color: Colors.white, size: 20)),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                            decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(10)),
                            child: Text('$_quantity', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          ),
                          GestureDetector(
                            onTap: () { if (_quantity < product.stock) setState(() => _quantity++); },
                            child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add, color: Colors.white, size: 20)),
                          ),
                          const Spacer(),
                          Text('${product.stock} in stock', style: TextStyle(color: product.stock <= 5 ? Colors.orange : AppTheme.gray, fontSize: 13, fontWeight: product.stock <= 5 ? FontWeight.w600 : FontWeight.w400)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Specifications
                      const Text('Specifications', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _specRow('SKU', product.sku),
                      _specRow('Category', product.categoryName ?? 'N/A'),
                      _specRow('Stock', '${product.stock} units'),
                      if (product.hasDiscount) _specRow('Discount', '${product.discountPercent}% off'),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Reviews Section
              SliverToBoxAdapter(
                child: _ReviewsSection(productId: product.id, reviewController: _reviewController, selectedRating: _selectedRating, onRatingChanged: (r) => setState(() => _selectedRating = r), onSubmit: () {
                  ref.read(reviewProvider.notifier).add(rating: _selectedRating, review: _reviewController.text.isNotEmpty ? _reviewController.text : null);
                  _reviewController.clear();
                  setState(() => _selectedRating = 5);
                }),
              ),

              // Related Products
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: const Text('You May Also Like', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: _RelatedProducts(categoryId: product.categoryId, currentProductId: product.id),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
      bottomNavigationBar: productAsync.when(
        data: (product) => Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(color: AppTheme.black, border: Border(top: BorderSide(color: AppTheme.darkGray))),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: product.stock == 0 ? null : () {
                      ref.read(cartProvider.notifier).add(
                        productId: product.id,
                        quantity: _quantity,
                        size: _selectedSize,
                        color: _selectedColor,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Added to cart'),
                          backgroundColor: AppTheme.gold,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          action: SnackBarAction(label: 'View Cart', textColor: AppTheme.black, onPressed: () => context.go('/cart')),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: AppTheme.black,
                      disabledBackgroundColor: AppTheme.darkGray,
                      disabledForegroundColor: AppTheme.gray,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(product.stock == 0 ? 'Out of Stock' : 'Add to Cart', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppTheme.gray, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showZoomDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsSection extends ConsumerWidget {
  final int productId;
  final TextEditingController reviewController;
  final int selectedRating;
  final Function(int) onRatingChanged;
  final VoidCallback onSubmit;

  const _ReviewsSection({
    required this.productId,
    required this.reviewController,
    required this.selectedRating,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(reviewProvider);
    final auth = ref.watch(authProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Reviews', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              if (reviewState.totalReviews > 0) ...[
                const Icon(Icons.star_rounded, color: AppTheme.gold, size: 18),
                const SizedBox(width: 4),
                Text('${reviewState.averageRating}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Text('(${reviewState.totalReviews})', style: const TextStyle(color: AppTheme.gray, fontSize: 13)),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Write review (if authenticated)
          if (auth.status == AuthStatus.authenticated) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Write a Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (i) => GestureDetector(
                      onTap: () => onRatingChanged(i + 1),
                      child: Icon(
                        i < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppTheme.gold,
                        size: 28,
                      ),
                    )),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reviewController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts...',
                      hintStyle: TextStyle(color: AppTheme.gray),
                      filled: true,
                      fillColor: AppTheme.black,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: AppTheme.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Review list
          if (reviewState.isLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          else if (reviewState.reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No reviews yet. Be the first!', style: TextStyle(color: AppTheme.gray))),
            )
          else
            ...reviewState.reviews.map((review) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(review.userName ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: AppTheme.gold,
                          size: 14,
                        )),
                      ),
                    ],
                  ),
                  if (review.review != null && review.review!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(review.review!, style: const TextStyle(color: AppTheme.gray, fontSize: 13)),
                  ],
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _RelatedProducts extends ConsumerWidget {
  final int categoryId;
  final int currentProductId;

  const _RelatedProducts({required this.categoryId, required this.currentProductId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      data: (data) {
        final products = (data['products'] as List<ProductModel>)
            .where((p) => p.categoryId == categoryId && p.id != currentProductId)
            .take(6)
            .toList();

        if (products.isEmpty) return const SizedBox.shrink();

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (ctx, i) {
            final p = products[i];
            return GestureDetector(
              onTap: () => context.push('/product/${p.slug}'),
              child: SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: p.image,
                          width: 150,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(color: AppTheme.darkGray),
                          errorWidget: (ctx, url, err) => Container(color: AppTheme.darkGray, child: const Icon(Icons.image, color: AppTheme.gray)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('\$${p.effectivePrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
