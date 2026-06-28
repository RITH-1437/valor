import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

final adminDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await ApiClient().dio.get('/admin/dashboard');
  return response.data['data'];
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: dashboardAsync.when(
        data: (data) {
          final stats = (data['stats'] as Map<String, dynamic>?) ?? {};
          final recentOrders = (data['recent_orders'] as List?) ?? [];
          final topProducts = (data['top_products'] as List?) ?? [];
          final lowStock = stats['low_stock_products'] ?? 0;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminDashboardProvider),
            color: AppTheme.gold,
            backgroundColor: AppTheme.darkGray,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _statCard('Total Revenue', '\$${(stats['total_revenue'] ?? 0).toStringAsFixed(0)}', FontAwesomeIcons.moneyBillTrendUp, AppTheme.gold),
                      _statCard('Total Orders', '${stats['total_orders'] ?? 0}', FontAwesomeIcons.bagShopping, Colors.blue),
                      _statCard('Total Products', '${stats['total_products'] ?? 0}', FontAwesomeIcons.boxesStacked, Colors.green),
                      _statCard('Total Users', '${stats['total_users'] ?? 0}', FontAwesomeIcons.users, Colors.purple),
                      _statCard('Pending Orders', '${stats['pending_orders'] ?? 0}', FontAwesomeIcons.clock, Colors.orange),
                      _statCard('Delivered', '${stats['delivered_orders'] ?? 0}', FontAwesomeIcons.circleCheck, Colors.green),
                      _statCard('Low Stock', '$lowStock', FontAwesomeIcons.triangleExclamation, lowStock > 0 ? Colors.redAccent : AppTheme.gray),
                      _statCard('Reviews', '${stats['total_reviews'] ?? 0}', FontAwesomeIcons.star, Colors.amber),
                    ],
                  ),

                  if (lowStock > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.redAccent.withAlpha(20), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent.withAlpha(50))),
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.redAccent, size: 24),
                          const SizedBox(width: 12),
                          Expanded(child: Text('$lowStock products are running low on stock', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),
                  ],

                  // Recent Orders
                  const SizedBox(height: 24),
                  const Text('Recent Orders', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...recentOrders.map((order) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(order['order_number'] ?? '', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(order['customer'] ?? '', style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
                          ]),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('\$${(order['total'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          _statusBadge(order['status'] ?? 'pending'),
                        ]),
                      ],
                    ),
                  )),

                  // Top Products
                  const SizedBox(height: 24),
                  const Text('Top Products', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...topProducts.map((product) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(child: Text(product['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13))),
                        Text('${product['sales'] ?? 0} sales', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
    );
  }

  Widget _statCard(String title, String value, dynamic icon, Color color) {
    Widget iconWidget = const SizedBox.shrink();
    if (icon is FaIconData) {
      iconWidget = FaIcon(icon, color: color, size: 18);
    } else if (icon is IconData) {
      iconWidget = Icon(icon, color: color, size: 22);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: AppTheme.gray, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'confirmed': color = Colors.blue; break;
      case 'processing': color = Colors.cyan; break;
      case 'shipped': color = AppTheme.gold; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.redAccent; break;
      default: color = AppTheme.gray;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}
