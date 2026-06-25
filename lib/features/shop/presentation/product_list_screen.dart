import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_product_provider.dart';
import '../../../core/providers/api_category_provider.dart';
import '../../../core/providers/api_wishlist_provider.dart';
import '../../../core/models/api_product.dart';
import '../../../core/models/api_category.dart';
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

  final _selectedCategories = <String>{};
  RangeValues _priceRange = const RangeValues(0, 500);
  String _sortBy = 'newest';
  bool _inStock = false;
  bool _featured = false;
  bool _trending = false;

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

  void _showFilterSheet() {
    final currentFilter = ref.read(productFilterProvider);
    _selectedCategories
      ..clear()
      ..addAll(currentFilter.category != null ? {currentFilter.category!} : {});
    _sortBy = currentFilter.sort ?? 'newest';
    _priceRange = RangeValues(
      currentFilter.minPrice ?? 0,
      currentFilter.maxPrice ?? 500,
    );

    final categoriesAsync = ref.read(categoriesProvider);
    final cats = categoriesAsync.value ?? <CategoryModel>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.gray,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              _selectedCategories.clear();
                              _priceRange = const RangeValues(0, 500);
                              _sortBy = 'newest';
                              _inStock = false;
                              _featured = false;
                              _trending = false;
                            });
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(color: AppTheme.gold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Category',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FilterChipGrid(
                      categories: cats,
                      selected: _selectedCategories,
                      onChanged: (v) {
                        setSheetState(() {
                          if (_selectedCategories.contains(v)) {
                            _selectedCategories.remove(v);
                          } else {
                            _selectedCategories.add(v);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Price Range',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      activeColor: AppTheme.gold,
                      inactiveColor: AppTheme.black,
                      labels: RangeLabels(
                        '\$${_priceRange.start.toInt()}',
                        '\$${_priceRange.end.toInt()}',
                      ),
                      onChanged: (v) {
                        setSheetState(() => _priceRange = v);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_priceRange.start.toInt()}',
                          style: const TextStyle(color: AppTheme.gray, fontSize: 13),
                        ),
                        Text(
                          '\$${_priceRange.end.toInt()}',
                          style: const TextStyle(color: AppTheme.gray, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Sort By',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SortOptions(
                      selected: _sortBy,
                      onChanged: (v) {
                        setSheetState(() => _sortBy = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Availability',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AvailabilityOptions(
                      inStock: _inStock,
                      featured: _featured,
                      trending: _trending,
                      onInStockChanged: (v) {
                        setSheetState(() => _inStock = v ?? false);
                      },
                      onFeaturedChanged: (v) {
                        setSheetState(() => _featured = v ?? false);
                      },
                      onTrendingChanged: (v) {
                        setSheetState(() => _trending = v ?? false);
                      },
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                _selectedCategories.clear();
                                _priceRange = const RangeValues(0, 500);
                                _sortBy = 'newest';
                                _inStock = false;
                                _featured = false;
                                _trending = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppTheme.gray),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Reset Filters',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _applyFilters();
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gold,
                              foregroundColor: AppTheme.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
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
    );
  }

  void _applyFilters() {
    final notifier = ref.read(productFilterProvider.notifier);
    if (_selectedCategories.isNotEmpty) {
      notifier.setCategory(_selectedCategories.first);
    } else {
      notifier.setCategory(null);
    }
    notifier.setSort(_sortBy);
    notifier.setMinPrice(_priceRange.start);
    notifier.setMaxPrice(_priceRange.end);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final filter = ref.watch(productFilterProvider);

    final hasActiveFilters = filter.category != null ||
        filter.sort != null ||
        filter.minPrice != null ||
        filter.maxPrice != null ||
        (filter.search != null && filter.search!.isNotEmpty);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.darkGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        ref.read(productFilterProvider.notifier).setSearch(v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: const TextStyle(color: AppTheme.gray),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.gray,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppTheme.gray,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(productFilterProvider.notifier)
                                    .setSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: _showFilterSheet,
                    icon: Badge(
                      isLabelVisible: hasActiveFilters,
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppTheme.gray,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active filter chips
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (filter.category != null)
                      _activeChip(
                        filter.category!,
                        () =>
                            ref.read(productFilterProvider.notifier).setCategory(
                              null,
                            ),
                      ),
                    if (filter.sort != null) ...[
                      const SizedBox(width: 6),
                      _activeChip(
                        _sortLabel(filter.sort!),
                        () =>
                            ref.read(productFilterProvider.notifier).setSort(
                              null,
                            ),
                      ),
                    ],
                    if (filter.minPrice != null || filter.maxPrice != null) ...[
                      const SizedBox(width: 6),
                      _activeChip(
                        '\$${filter.minPrice?.toInt() ?? 0}-\$${filter.maxPrice?.toInt() ?? 500}',
                        () {
                          ref
                              .read(productFilterProvider.notifier)
                              .setMinPrice(null);
                          ref
                              .read(productFilterProvider.notifier)
                              .setMaxPrice(null);
                        },
                      ),
                    ],
                    if (filter.search != null && filter.search!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _activeChip(
                        '"${filter.search}"',
                        () {
                          _searchController.clear();
                          ref
                              .read(productFilterProvider.notifier)
                              .setSearch('');
                        },
                      ),
                    ],
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () {
                        ref.read(productFilterProvider.notifier).reset();
                        _searchController.clear();
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 4),

          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (data) {
                final products = data['products'] as List<ProductModel>;
                if (products.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      _ProductCard(product: products[index]),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.gold),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: AppTheme.gray),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.gold.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.clear_all_rounded,
              size: 14,
              color: AppTheme.gold,
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(String sort) {
    switch (sort) {
      case 'newest':
        return 'Newest';
      case 'price_asc':
        return 'Price: Low to High';
      case 'price_desc':
        return 'Price: High to Low';
      case 'popular':
        return 'Most Popular';
      default:
        return sort;
    }
  }
}

class _FilterChipGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final Set<String> selected;
  final ValueChanged<String> onChanged;

  const _FilterChipGrid({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = selected.contains(cat.slug);
        return GestureDetector(
          onTap: () => onChanged(cat.slug),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.gold : AppTheme.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.gold : const Color(0xFF374151),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 16,
                  color: isSelected ? AppTheme.black : AppTheme.gray,
                ),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SortOptions extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _SortOptions({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('newest', 'Newest'),
      ('price_asc', 'Price Low to High'),
      ('price_desc', 'Price High to Low'),
      ('popular', 'Most Popular'),
    ];

    return Column(
      children: options.map((opt) {
        final isSelected = selected == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.gold.withAlpha(25) : AppTheme.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.gold : const Color(0xFF374151),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: isSelected ? AppTheme.gold : AppTheme.gray,
                ),
                const SizedBox(width: 10),
                Text(
                  opt.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.gold : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AvailabilityOptions extends StatelessWidget {
  final bool inStock;
  final bool featured;
  final bool trending;
  final ValueChanged<bool?> onInStockChanged;
  final ValueChanged<bool?> onFeaturedChanged;
  final ValueChanged<bool?> onTrendingChanged;

  const _AvailabilityOptions({
    required this.inStock,
    required this.featured,
    required this.trending,
    required this.onInStockChanged,
    required this.onFeaturedChanged,
    required this.onTrendingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _checkItem('In Stock', inStock, onInStockChanged),
        const SizedBox(height: 8),
        _checkItem('Featured', featured, onFeaturedChanged),
        const SizedBox(height: 8),
        _checkItem('Trending', trending, onTrendingChanged),
      ],
    );
  }

  Widget _checkItem(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF374151)),
        ),
        child: Row(
          children: [
            Icon(
              value
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 20,
              color: value ? AppTheme.gold : AppTheme.gray,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
    final isWishlisted =
        wishlist.value?.any((w) => w.productId == product.id) ?? false;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('/product/${product.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.darkGray,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: 'product_${product.id}',
                          child: CachedNetworkImage(
                            imageUrl: product.image,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => Container(
                              color: AppTheme.black,
                              child: const Center(
                                child: Icon(
                                  Icons.image_rounded,
                                  color: AppTheme.gray,
                                  size: 40,
                                ),
                              ),
                            ),
                            errorWidget: (ctx, url, err) => Container(
                              color: AppTheme.black,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: AppTheme.gray,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (product.isFeatured)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FEATURED',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      if (product.isTrending && !product.isFeatured)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'TRENDING',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      if (product.hasDiscount)
                        Positioned(
                          top: 8,
                          right: 36,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.gold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${product.discountPercent}%',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                        ),
                      if (product.stock <= 5 && product.stock > 0)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(180),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Only ${product.stock} left',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (product.stock == 0)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            if (isWishlisted) {
                              ref
                                  .read(wishlistProvider.notifier)
                                  .remove(product.id);
                            } else {
                              ref
                                  .read(wishlistProvider.notifier)
                                  .add(product.id);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.black,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                              color: isWishlisted
                                  ? AppTheme.gold
                                  : Colors.white70,
                            ),
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
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (product.hasDiscount)
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.gray,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (product.hasDiscount) const SizedBox(width: 6),
                        Text(
                          '\$${product.effectivePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
