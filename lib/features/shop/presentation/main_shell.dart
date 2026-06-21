import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_cart_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.value?.items.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0;
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/shop')) {
      currentIndex = 1;
    } else if (location.startsWith('/wishlist')) {
      currentIndex = 2;
    } else if (location.startsWith('/cart')) {
      currentIndex = 3;
    } else if (location.startsWith('/profile')) {
      currentIndex = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.darkGray))),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) {
            switch (i) {
              case 0: context.go('/home');
              case 1: context.go('/shop');
              case 2: context.go('/wishlist');
              case 3: context.go('/cart');
              case 4: context.go('/profile');
            }
          },
          backgroundColor: AppTheme.black,
          selectedItemColor: AppTheme.gold,
          unselectedItemColor: AppTheme.gray,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Shop'),
            const BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Wishlist'),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount', style: const TextStyle(fontSize: 10)),
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
