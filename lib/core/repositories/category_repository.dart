import '../models/api_category.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
}

class ApiCategoryRepository implements CategoryRepository {
  final _client = ApiClient().dio;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get(ApiConstants.categories);
    final data = response.data['data'] as List;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }
}
