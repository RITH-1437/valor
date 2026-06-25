import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repositories.dart';
import '../models/api_category.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiCategoryRepository() : MockCategoryRepository();
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(categoryRepositoryProvider).getCategories();
});
