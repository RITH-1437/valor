import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_order_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('My Orders')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Your order history will appear here',
              actionLabel: 'Start Shopping',
              onAction: () => context.go('/shop'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final order = orders[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          _statusBadge(order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppTheme.gray,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...order.items.take(2).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${item.product?.name ?? 'Product'} x${item.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (order.items.length > 2)
                        Text(
                          '+${order.items.length - 2} more',
                          style: const TextStyle(
                            color: AppTheme.gray,
                            fontSize: 11,
                          ),
                        ),
                      const Divider(color: AppTheme.black, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          if (order.createdAt != null)
                            Text(
                              '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}',
                              style: const TextStyle(
                                color: AppTheme.gray,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.gold),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray)),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case 'processing':
        color = Colors.cyan;
        label = 'Processing';
        break;
      case 'shipped':
        color = AppTheme.gold;
        label = 'Shipped';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.redAccent;
        label = 'Cancelled';
        break;
      default:
        color = AppTheme.gray;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
