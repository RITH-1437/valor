import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_product.dart';
import '../repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.read(productRepositoryProvider).getFeatured();
});

final trendingProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.read(productRepositoryProvider).getTrending();
});

final productBySlugProvider = FutureProvider.family<ProductModel, String>((ref, slug) async {
  return ref.read(productRepositoryProvider).getProductBySlug(slug);
});

class ProductFilter {
  final String? search;
  final String? category;
  final String? sort;
  final double? minPrice;
  final double? maxPrice;
  final int page;

  const ProductFilter({this.search, this.category, this.sort, this.minPrice, this.maxPrice, this.page = 1});

  ProductFilter copyWith({String? search, String? category, String? sort, double? minPrice, double? maxPrice, int? page, bool clearSearch = false, bool clearCategory = false, bool clearSort = false, bool clearMinPrice = false, bool clearMaxPrice = false}) {
    return ProductFilter(
      search: clearSearch ? null : (search ?? this.search),
      category: clearCategory ? null : (category ?? this.category),
      sort: clearSort ? null : (sort ?? this.sort),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      page: page ?? this.page,
    );
  }
}

final productFilterProvider = NotifierProvider<ProductFilterNotifier, ProductFilter>(ProductFilterNotifier.new);

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void setSearch(String v) => state = state.copyWith(search: v, clearSearch: v.isEmpty);
  void setCategory(String? v) => state = state.copyWith(category: v, clearCategory: v == null);
  void setSort(String? v) => state = state.copyWith(sort: v, clearSort: v == null);
  void reset() => state = const ProductFilter();
}

final productsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final filter = ref.watch(productFilterProvider);
  return ref.read(productRepositoryProvider).getProducts(
    page: filter.page,
    search: filter.search,
    category: filter.category,
    sort: filter.sort,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
  );
});
