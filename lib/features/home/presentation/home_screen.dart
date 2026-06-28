import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/api_category.dart';
import '../../../core/models/api_product.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/api_category_provider.dart';
import '../../../core/providers/api_product_provider.dart';

dynamic _categoryIcon(String slug) {
  switch (slug) {
    case 't-shirts': return FontAwesomeIcons.shirt;
    case 'shirts': return FontAwesomeIcons.shirt;
    case 'jeans': return FontAwesomeIcons.bagShopping;
    case 'pants': return FontAwesomeIcons.ruler;
    case 'outerwear': return FontAwesomeIcons.personHiking;
    case 'shoes': return FontAwesomeIcons.personRunning;
    case 'watches': return FontAwesomeIcons.clock;
    case 'accessories': return FontAwesomeIcons.gem;
    case 'bags': return FontAwesomeIcons.briefcase;
    default: return FontAwesomeIcons.list;
  }
}

const _brands = ['Gucci', 'Prada', 'Versace', 'Armani', 'Balenciaga', 'Saint Laurent', 'Valentino', 'Burberry'];
final _promotions = <Map<String, dynamic>>[
  {'title': 'Summer Sale', 'subtitle': 'Up to 40% off', 'color': const Color(0xFFFF6B6B)},
  {'title': 'New Collection', 'subtitle': 'Spring/Summer 2026', 'color': const Color(0xFF6C63FF)},
  {'title': 'Free Shipping', 'subtitle': r'On orders over $150', 'color': const Color(0xFF00C9A7)},
];
const _lookbookItems = [
  {'title': 'Street Style', 'image': 'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=600&h=800&fit=crop'},
  {'title': 'Evening Elegance', 'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=800&fit=crop'},
  {'title': 'Casual Luxe', 'image': 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=600&h=800&fit=crop'},
  {'title': 'Modern Minimal', 'image': 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=600&h=800&fit=crop'},
];

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
            SliverToBoxAdapter(child: SafeArea(child: _HeroBanner(userName: auth.user?.name ?? 'Guest'))),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0), child: _SearchBar())),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 0), child: _SectionHeader(title: 'Categories', onSeeAll: () => context.push('/shop')))),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), child: _CategoryCarousel(categories: categories))),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _BrandStrip())),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _PromotionsRow())),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0), child: _LookbookSection())),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: _SectionHeader(title: 'New Arrivals', onSeeAll: () => context.push('/shop?sort=newest')))),
            featured.when(
              data: (products) {
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Text('No new arrivals found', style: TextStyle(color: AppTheme.gray)),
                    ),
                  );
                }
                return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(bottom: 24), child: _ProductCarousel(products: products)));
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppTheme.gold)))),
              error: (e, st) => SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Error loading arrivals: $e', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              )),
            ),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: _SectionHeader(title: 'Best Sellers', onSeeAll: () => context.push('/shop?sort=popular')))),
            trending.when(
              data: (products) {
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox(height: 40));
                }
                return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(bottom: 40), child: _ProductCarousel(products: products)));
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppTheme.gold)))),
              error: (_, _) => const SliverToBoxAdapter(child: SizedBox(height: 200)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final String userName;
  const _HeroBanner({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1617137968427-85924c800a22?w=800&h=600&fit=crop'),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withAlpha(10), Colors.black.withAlpha(200)],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppTheme.black.withAlpha(220)],
        )),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, $userName', style: const TextStyle(fontSize: 14, color: AppTheme.gray)),
                        const SizedBox(height: 4),
                        const Text('Elevate Your Style', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/map'),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.darkGray)),
                      child: const Center(child: FaIcon(FontAwesomeIcons.map, color: AppTheme.gold, size: 26)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => context.push('/shop'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 20)),
                  child: const Text('Shop Now', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/shop'),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const FaIcon(FontAwesomeIcons.magnifyingGlass, color: AppTheme.gray, size: 22),
            const SizedBox(width: 12),
            const Expanded(child: Text('Search products...', style: TextStyle(fontSize: 14, color: AppTheme.gray))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.gold.withAlpha(30), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.sliders, color: AppTheme.gold, size: 16),
                  SizedBox(width: 4),
                  Text('Filter', style: TextStyle(fontSize: 12, color: AppTheme.gold, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Row(
              children: [
                Text('See All', style: TextStyle(fontSize: 13, color: AppTheme.gold, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                FaIcon(FontAwesomeIcons.chevronRight, color: AppTheme.gold, size: 12),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoryCarousel extends StatelessWidget {
  final AsyncValue<List<CategoryModel>> categories;
  const _CategoryCarousel({required this.categories});

  @override
  Widget build(BuildContext context) {
    return categories.when(
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
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: AppTheme.darkGray, shape: BoxShape.circle, border: Border.all(color: AppTheme.darkGray)),
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final icon = _categoryIcon(cat.slug);
                          if (icon is FaIconData) {
                            return FaIcon(icon, color: AppTheme.gold, size: 28);
                          } else if (icon is IconData) {
                            return Icon(icon, color: AppTheme.gold, size: 28);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
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
    );
  }
}

class _BrandStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _brands.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.darkGray,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.darkGray),
          ),
          child: Center(child: Text(_brands[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
        ),
      ),
    );
  }
}

class _PromotionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _promotions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final p = _promotions[i];
          final color = p['color'] as Color;
          return Container(
            width: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(p['subtitle'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.gray)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LookbookSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Lookbook'),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _lookbookItems.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final item = _lookbookItems[i];
              return GestureDetector(
                onTap: () => context.push('/shop'),
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(
                    image: NetworkImage(item['image'] as String), fit: BoxFit.cover,
                  )),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withAlpha(200), Colors.transparent]),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    child: Text(item['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCarousel extends StatelessWidget {
  final List<ProductModel> products;
  const _ProductCarousel({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => _CarouselCard(product: products[i]),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final ProductModel product;
  const _CarouselCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.slug}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.image, width: double.infinity, fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: AppTheme.black, child: const Center(child: FaIcon(FontAwesomeIcons.image, color: AppTheme.gray, size: 30))),
                      errorWidget: (_, _, _) => Container(color: AppTheme.black, child: const Center(child: FaIcon(FontAwesomeIcons.image, color: AppTheme.gray, size: 30))),
                    ),
                    if (product.hasDiscount)
                      Positioned(top: 8, left: 8, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(4)),
                        child: Text('-${product.discountPercent}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.black)),
                      )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.hasDiscount)
                        Text('\$${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppTheme.gray, decoration: TextDecoration.lineThrough)),
                      if (product.hasDiscount) const SizedBox(width: 4),
                      Text('\$${product.effectivePrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
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
