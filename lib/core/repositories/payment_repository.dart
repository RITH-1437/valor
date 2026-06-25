import '../models/api_payment.dart';
import '../network/api_client.dart';

abstract class PaymentRepository {
  Future<PaymentTransactionModel> createPayment({required int orderId, required String provider, required String paymentMethod});
  Future<PaymentTransactionModel> verifyPayment(int transactionId, String status);
  Future<List<PaymentTransactionModel>> getPaymentHistory();
}

class ApiPaymentRepository implements PaymentRepository {
  final _client = ApiClient().dio;

  @override
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

  @override
  Future<PaymentTransactionModel> verifyPayment(int transactionId, String status) async {
    final response = await _client.post('/payments/$transactionId/verify', data: {
      'status': status,
    });
    return PaymentTransactionModel.fromJson(response.data['data']);
  }

  @override
  Future<List<PaymentTransactionModel>> getPaymentHistory() async {
    final response = await _client.get('/payments/history');
    final data = response.data['data'] as List;
    return data.map((e) => PaymentTransactionModel.fromJson(e)).toList();
  }
}
