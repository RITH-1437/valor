import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) => AIRepository());

class AIRepository {
  final _client = ApiClient().dio;

  Future<Map<String, dynamic>> recommendSize({
    required int heightCm,
    required int weightKg,
    String? bodyType,
  }) async {
    final response = await _client.post('/ai/size-recommendation', data: {
      'height_cm': heightCm,
      'weight_kg': weightKg,
      if (bodyType != null) 'body_type': bodyType, // ignore: use_null_aware_elements
    });
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getOutfitRecommendation(int productId, String occasion) async {
    final response = await _client.post('/products/$productId/stylist', data: {
      'occasion': occasion,
    });
    return response.data['data'];
  }
}
