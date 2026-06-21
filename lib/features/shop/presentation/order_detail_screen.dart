import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/api_order.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusSteps = ['pending', 'confirmed', 'processing', 'shipped', 'delivered'];
    final currentStep = statusSteps.indexOf(order.status);
    final isCancelled = order.status == 'cancelled';

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: Text(order.orderNumber)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkGray,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor(order.status).withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _statusBadge(order.status),
                      const Spacer(),
                      if (order.createdAt != null)
                        Text('${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}', style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Total: \$${order.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Payment: ${order.paymentMethod.replaceAll('_', ' ').toUpperCase()}', style: const TextStyle(color: AppTheme.gray, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tracking Timeline
            if (!isCancelled) ...[
              const Text('Order Status', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...List.generate(statusSteps.length, (i) {
                final isActive = i <= currentStep;
                final isCurrent = i == currentStep;
                return _TrackingStep(
                  title: _stepTitle(statusSteps[i]),
                  subtitle: _stepSubtitle(statusSteps[i]),
                  isActive: isActive,
                  isCurrent: isCurrent,
                  isLast: i == statusSteps.length - 1,
                );
              }),
              const SizedBox(height: 24),
            ],

            // Items
            const Text('Order Items', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.product?.image ?? '',
                      width: 60,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(width: 60, height: 70, color: AppTheme.black),
                      errorWidget: (context, url, error) => Container(width: 60, height: 70, color: AppTheme.black, child: const Icon(Icons.image, color: AppTheme.gray)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product?.name ?? 'Product', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Qty: ${item.quantity}', style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
                ],
              ),
            )),
            const SizedBox(height: 16),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _summaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _summaryRow('Shipping', order.shippingFee == 0 ? 'FREE' : '\$${order.shippingFee.toStringAsFixed(2)}'),
                  const Divider(color: AppTheme.black, height: 16),
                  _summaryRow('Total', '\$${order.total.toStringAsFixed(2)}', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Shipping Address
            const Text('Shipping Address', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(order.shippingAddress, style: const TextStyle(color: AppTheme.gray, fontSize: 14)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'processing': return Colors.cyan;
      case 'shipped': return AppTheme.gold;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.redAccent;
      default: return AppTheme.gray;
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: _statusColor(status).withAlpha(50), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
    );
  }

  String _stepTitle(String status) {
    switch (status) {
      case 'pending': return 'Order Placed';
      case 'confirmed': return 'Confirmed';
      case 'processing': return 'Processing';
      case 'shipped': return 'Shipped';
      case 'delivered': return 'Delivered';
      default: return status;
    }
  }

  String _stepSubtitle(String status) {
    switch (status) {
      case 'pending': return 'Your order has been received';
      case 'confirmed': return 'Order confirmed by seller';
      case 'processing': return 'Your order is being prepared';
      case 'shipped': return 'Your order is on the way';
      case 'delivered': return 'Order delivered successfully';
      default: return '';
    }
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.white : AppTheme.gray, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(color: isTotal ? Colors.white : AppTheme.gold, fontWeight: FontWeight.w700, fontSize: isTotal ? 18 : 14)),
      ],
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;

  const _TrackingStep({required this.title, required this.subtitle, required this.isActive, required this.isCurrent, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.gold : AppTheme.darkGray,
                shape: BoxShape.circle,
                border: Border.all(color: isActive ? AppTheme.gold : const Color(0xFF374151), width: 2),
              ),
              child: isActive ? const Icon(Icons.check, size: 14, color: AppTheme.black) : null,
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: isActive ? AppTheme.gold : const Color(0xFF374151)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isActive ? Colors.white : AppTheme.gray, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: TextStyle(color: isActive ? AppTheme.gray : const Color(0xFF374151), fontSize: 12)),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}
