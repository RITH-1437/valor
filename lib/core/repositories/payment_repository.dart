import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_payment.dart';
import '../network/api_client.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) => PaymentRepository());

class PaymentRepository {
  final _client = ApiClient().dio;

  Future<PaymentTransactionModel> createPayment({
    required int orderId,
    required String provider,
    required String paymentMethod,
  }) async {
    final response = await _client.post('/payments/create', data: {
      'order_id': orderId,
      'provider': provider,
      'payment_method': paymentMethod,
    });
    return PaymentTransactionModel.fromJson(response.data['data']);
  }

  Future<PaymentTransactionModel> verifyPayment(int transactionId, String status) async {
    final response = await _client.post('/payments/$transactionId/verify', data: {
      'status': status,
    });
    return PaymentTransactionModel.fromJson(response.data['data']);
  }

  Future<List<PaymentTransactionModel>> getPaymentHistory() async {
    final response = await _client.get('/payments/history');
    final data = response.data['data'] as List;
    return data.map((e) => PaymentTransactionModel.fromJson(e)).toList();
  }
}
