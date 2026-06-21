import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_cart_provider.dart';
import '../../../core/models/api_cart.dart';
import '../../../shared/widgets/empty_state.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: cartAsync.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Browse our collection and find something you love',
              actionLabel: 'Start Shopping',
              onAction: () => context.go('/shop'),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) => _CartItemCard(
                    item: cart.items[i],
                    onRemove: () => ref.read(cartProvider.notifier).remove(cart.items[i].id),
                    onUpdateQuantity: (qty) => ref.read(cartProvider.notifier).updateQuantity(cart.items[i].id, qty),
                  ),
                ),
              ),
              if (cart.meta != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Column(
                    children: [
                      _summaryRow('Subtotal', '\$${cart.meta!.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _summaryRow('Shipping', cart.meta!.shipping == 0 ? 'FREE' : '\$${cart.meta!.shipping.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _summaryRow('Tax', '\$${cart.meta!.tax.toStringAsFixed(2)}'),
                      const Divider(color: AppTheme.gray, height: 24),
                      _summaryRow('Total', '\$${cart.meta!.total.toStringAsFixed(2)}', isTotal: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/checkout'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: AppTheme.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: const Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.white : AppTheme.gray, fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(color: isTotal ? Colors.white : AppTheme.gray, fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;
  final Function(int) onUpdateQuantity;

  const _CartItemCard({required this.item, required this.onRemove, required this.onUpdateQuantity});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final imageUrl = product?.image ?? '';
    final name = product?.name ?? 'Product';
    final price = product?.effectivePrice ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 90,
              height: 110,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(width: 90, height: 110, color: AppTheme.black, child: const Center(child: Icon(Icons.image, color: AppTheme.gray))),
              errorWidget: (ctx, url, err) => Container(width: 90, height: 110, color: AppTheme.black, child: const Center(child: Icon(Icons.broken_image, color: AppTheme.gray))),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (item.selectedSize != null || item.selectedColor != null)
                  Text('${item.selectedSize ?? ''} / ${item.selectedColor ?? ''}', style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
                const SizedBox(height: 4),
                Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () { if (item.quantity > 1) onUpdateQuantity(item.quantity - 1); },
                      child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.remove, size: 16, color: Colors.white)),
                    ),
                    Container(margin: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                    GestureDetector(
                      onTap: () => onUpdateQuantity(item.quantity + 1),
                      child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.add, size: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(onTap: onRemove, child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, color: AppTheme.gray, size: 18))),
        ],
      ),
    );
  }
}
