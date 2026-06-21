import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
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
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', pageBuilder: (context, state) => NoTransitionPage(child: const HomeScreen())),
        GoRoute(path: '/shop', pageBuilder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return NoTransitionPage(child: ProductListScreen(category: category, title: category != null ? '${category.toUpperCase()} Products' : 'Shop All'));
        }),
        GoRoute(path: '/wishlist', pageBuilder: (context, state) => NoTransitionPage(child: const WishlistScreen())),
        GoRoute(path: '/cart', pageBuilder: (context, state) => NoTransitionPage(child: const CartScreen())),
        GoRoute(path: '/profile', pageBuilder: (context, state) => NoTransitionPage(child: const ProfileScreen())),
      ],
    ),
    GoRoute(
      path: '/product/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return ProductDetailScreen(productId: slug);
      },
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
