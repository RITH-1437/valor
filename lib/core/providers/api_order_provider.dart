import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repositories.dart';
import '../models/api_order.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import '../repositories/order_repository.dart';
import 'auth_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiOrderRepository() : MockOrderRepository();
});

class OrderNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return [];
    return ref.read(orderRepositoryProvider).getOrders();
  }

  Future<OrderModel?> placeOrder({required String shippingAddress, required String paymentMethod}) async {
    try {
      final order = await ref.read(orderRepositoryProvider).placeOrder(shippingAddress: shippingAddress, paymentMethod: paymentMethod);
      ref.invalidateSelf();
      return order;
    } catch (_) {
      return null;
    }
  }
}

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<OrderModel>>(OrderNotifier.new);
