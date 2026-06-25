import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/branch_map_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/shop/presentation/product_list_screen.dart';
import '../../features/shop/presentation/product_detail_screen.dart';
import '../../features/shop/presentation/cart_screen.dart';
import '../../features/shop/presentation/wishlist_screen.dart';
import '../../features/shop/presentation/checkout_screen.dart';
import '../../features/shop/presentation/orders_screen.dart';
import '../../features/shop/presentation/profile_screen.dart';
import '../../features/shop/presentation/address_screen.dart';
import '../../features/shop/presentation/payment_history_screen.dart';
import '../../features/shop/presentation/notification_screen.dart';
import '../../features/shop/presentation/admin_panel_screen.dart';
import '../../features/shop/presentation/settings_screen.dart';
import '../../features/shop/presentation/main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/onboarding', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/map', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const BranchMapScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/shop', builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ProductListScreen(category: category, title: category != null ? '${category.toUpperCase()} Products' : 'Shop All');
            }),
            GoRoute(
              path: '/product/:slug',
              builder: (context, state) {
                final slug = state.pathParameters['slug'] ?? '';
                return ProductDetailScreen(productId: slug);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/wishlist', builder: (context, state) => const WishlistScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),
      ],
    ),
    GoRoute(path: '/checkout', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const CheckoutScreen()),
    GoRoute(path: '/orders', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const OrdersScreen()),
    GoRoute(path: '/addresses', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const AddressScreen()),
    GoRoute(path: '/payment-history', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const PaymentHistoryScreen()),
    GoRoute(path: '/notifications', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const NotificationScreen()),
    GoRoute(path: '/admin', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const AdminPanelScreen()),
    GoRoute(path: '/settings', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SettingsScreen()),
  ],
);
