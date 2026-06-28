import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_cart_provider.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.value?.items.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.darkGray))),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (i) => navigationShell.goBranch(i),
          backgroundColor: AppTheme.black,
          selectedItemColor: AppTheme.gold,
          unselectedItemColor: AppTheme.gray,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: 'Home'),
            const BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.bagShopping, size: 20), label: 'Shop'),
            const BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.heart, size: 20), label: 'Wishlist'),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount', style: const TextStyle(fontSize: 10)),
                child: const FaIcon(FontAwesomeIcons.cartShopping, size: 20),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.user, size: 20), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
