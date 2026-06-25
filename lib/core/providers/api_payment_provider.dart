import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repositories.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import '../repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiPaymentRepository() : MockPaymentRepository();
});
