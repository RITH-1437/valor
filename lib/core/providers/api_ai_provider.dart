import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repositories.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import '../repositories/ai_repository.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiAIRepository() : MockAIRepository();
});
