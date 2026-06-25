import '../network/api_client.dart';

abstract class AIRepository {
  Future<Map<String, dynamic>> recommendSize({required int heightCm, required int weightKg, String? bodyType});
  Future<Map<String, dynamic>> getOutfitRecommendation(int productId, String occasion);
}

class ApiAIRepository implements AIRepository {
  final _client = ApiClient().dio;

  @override
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

  @override
  Future<Map<String, dynamic>> getOutfitRecommendation(int productId, String occasion) async {
    final response = await _client.post('/products/$productId/stylist', data: {
      'occasion': occasion,
    });
    return response.data['data'];
  }
}
