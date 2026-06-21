import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

final adminProductsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await ApiClient().dio.get('/admin/products');
  return response.data;
});

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.gold),
            onPressed: () {},
          ),
        ],
      ),
      body: productsAsync.when(
        data: (data) {
          final products = data['data']?['data'] as List? ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final p = products[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: AppTheme.black,
                        child: p['image'] != null && (p['image'] as String).isNotEmpty
                            ? Image.network(p['image'], fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.image, color: AppTheme.gray))
                            : const Icon(Icons.image, color: AppTheme.gray),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          Text('\$${(p['price'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Text('Stock: ${p['stock'] ?? 0}', style: TextStyle(color: (p['stock'] ?? 0) < 10 ? Colors.redAccent : AppTheme.gray, fontSize: 11)),
                        ]),
                      ]),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: AppTheme.gray),
                      color: AppTheme.darkGray,
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: Colors.white))),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
                      ],
                      onSelected: (v) {},
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
    );
  }
}
