import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _currentIndex = 0;

  final _screens = [
    const AdminDashboardScreen(),
    const AdminProductsScreen(),
    const Center(child: Text('Orders', style: TextStyle(color: AppTheme.gray))),
    const Center(child: Text('Customers', style: TextStyle(color: AppTheme.gray))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.darkGray))),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppTheme.black,
          selectedItemColor: AppTheme.gold,
          unselectedItemColor: AppTheme.gray,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          ],
        ),
      ),
    );
  }
}
