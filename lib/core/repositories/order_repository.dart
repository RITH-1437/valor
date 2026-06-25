import '../models/api_order.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

abstract class OrderRepository {
  Future<OrderModel> placeOrder({required String shippingAddress, required String paymentMethod});
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrder(int id);
}

class ApiOrderRepository implements OrderRepository {
  final _client = ApiClient().dio;

  @override
  Future<OrderModel> placeOrder({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    final response = await _client.post(ApiConstants.orders, data: {
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
    });
    return OrderModel.fromJson(response.data['data']);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _client.get(ApiConstants.orders);
    final data = response.data['data'] as List;
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  @override
  Future<OrderModel> getOrder(int id) async {
    final response = await _client.get('${ApiConstants.orders}/$id');
    return OrderModel.fromJson(response.data['data']);
  }
}
