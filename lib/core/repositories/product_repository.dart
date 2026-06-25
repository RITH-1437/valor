import '../models/api_product.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

abstract class ProductRepository {
  Future<Map<String, dynamic>> getProducts({int page = 1, int perPage = 20, String? search, String? category, String? sort, double? minPrice, double? maxPrice});
  Future<List<ProductModel>> getFeatured();
  Future<List<ProductModel>> getTrending();
  Future<ProductModel> getProductBySlug(String slug);
}

class ApiProductRepository implements ProductRepository {
  final _client = ApiClient().dio;

  @override
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    String? category,
    String? sort,
    double? minPrice,
    double? maxPrice,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null) params['category'] = category;
    if (sort != null) params['sort'] = sort;
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;

    final response = await _client.get(ApiConstants.products, queryParameters: params);
    final data = response.data;
    return {
      'products': (data['data'] as List).map((e) => ProductModel.fromJson(e)).toList(),
      'meta': data['meta'],
    };
  }

  @override
  Future<List<ProductModel>> getFeatured() async {
    final response = await _client.get(ApiConstants.featuredProducts);
    final data = response.data['data'] as List;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<List<ProductModel>> getTrending() async {
    final response = await _client.get(ApiConstants.trendingProducts);
    final data = response.data['data'] as List;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _client.get('${ApiConstants.products}/$slug');
    return ProductModel.fromJson(response.data['data']);
  }
}
