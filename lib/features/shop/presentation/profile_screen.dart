import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/api_order_provider.dart';
import '../../../core/providers/api_wishlist_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final orders = ref.watch(orderProvider);
    final wishlist = ref.watch(wishlistProvider);

    final user = auth.user;
    final orderCount = orders.value?.length ?? 0;
    final wishlistCount = wishlist.value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.gold, width: 3),
                image: user?.avatar != null
                    ? DecorationImage(image: NetworkImage(user!.avatar!), fit: BoxFit.cover)
                    : null,
              ),
              child: user?.avatar == null
                  ? const Icon(Icons.person, color: AppTheme.gray, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(user?.name ?? 'Guest', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: const TextStyle(color: AppTheme.gray, fontSize: 14)),
            const SizedBox(height: 32),
            Row(
              children: [
                _statCard('Orders', '$orderCount'),
                const SizedBox(width: 12),
                _statCard('Wishlist', '$wishlistCount'),
              ],
            ),
            const SizedBox(height: 32),
            _menuItem(context, Icons.shopping_bag_outlined, 'My Orders', AppTheme.gold, () => context.push('/orders')),
            const SizedBox(height: 8),
            _menuItem(context, Icons.favorite_outline, 'Wishlist', Colors.redAccent, () => context.push('/wishlist')),
            const SizedBox(height: 8),
            _menuItem(context, Icons.location_on_outlined, 'Shipping Addresses', AppTheme.gray, () => context.push('/addresses')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: AppTheme.gold, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: AppTheme.gray, size: 20),
          ],
        ),
      ),
    );
  }
}
