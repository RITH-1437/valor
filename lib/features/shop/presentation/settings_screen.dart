import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme section
            const Text('Appearance', style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            _themeOption(ref, 'Dark Mode', Icons.dark_mode_outlined, AppThemeMode.dark, themeMode),
            _themeOption(ref, 'Light Mode', Icons.light_mode_outlined, AppThemeMode.light, themeMode),
            _themeOption(ref, 'System Default', Icons.brightness_auto_outlined, AppThemeMode.system, themeMode),
            const SizedBox(height: 24),

            // Account section
            const Text('Account', style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            _menuItem(Icons.edit_outlined, 'Edit Profile', () {}),
            _menuItem(Icons.lock_outline, 'Change Password', () {}),
            _menuItem(Icons.location_on_outlined, 'Shipping Addresses', () => context.push('/addresses')),
            _menuItem(Icons.credit_card_rounded, 'Payment History', () => context.push('/payment-history')),
            const SizedBox(height: 24),

            // Support
            const Text('Support', style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            _menuItem(Icons.help_outline, 'Help Center', () {}),
            _menuItem(Icons.description_outlined, 'Terms of Service', () {}),
            _menuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
            const SizedBox(height: 24),

            // App info
            const Text('About', style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            _menuItem(Icons.info_outline, 'App Version', () {}, subtitle: '1.0.0'),
            const SizedBox(height: 32),

            // Logout
            if (auth.status == AuthStatus.authenticated)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
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

  Widget _themeOption(WidgetRef ref, String title, IconData icon, AppThemeMode mode, AppThemeMode current) {
    final selected = current == mode;
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).setTheme(mode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold.withAlpha(25) : AppTheme.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.gold : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppTheme.gold : AppTheme.gray, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: selected ? AppTheme.gold : Colors.white, fontWeight: FontWeight.w600))),
            if (selected) const Icon(Icons.check_circle, color: AppTheme.gold, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {String? subtitle}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.gray, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            if (subtitle != null) Text(subtitle, style: const TextStyle(color: AppTheme.gray, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.gray, size: 20),
          ],
        ),
      ),
    );
  }
}
