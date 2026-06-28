import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            _themeOption(ref, 'Dark Mode', FontAwesomeIcons.moon, AppThemeMode.dark, themeMode),
            _themeOption(ref, 'Light Mode', FontAwesomeIcons.sun, AppThemeMode.light, themeMode),
            _themeOption(ref, 'System Default', FontAwesomeIcons.circleHalfStroke, AppThemeMode.system, themeMode),
            const SizedBox(height: 24),

            // Account section
            const Text('Account', style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            _menuItem(FontAwesomeIcons.penToSquare, 'Edit Profile', () {}),
            _menuItem(FontAwesomeIcons.lock, 'Change Password', () {}),
            _menuItem(FontAwesomeIcons.locationDot, 'Shipping Addresses', () => context.push('/addresses')),
            _menuItem(FontAwesomeIcons.creditCard, 'Payment History', () => context.push('/payment-history')),
            const SizedBox(height: 24),

            // Support
            const Text('Support', style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            _menuItem(FontAwesomeIcons.circleQuestion, 'Help Center', () {}),
            _menuItem(FontAwesomeIcons.fileLines, 'Terms of Service', () {}),
            _menuItem(FontAwesomeIcons.shieldHalved, 'Privacy Policy', () {}),
            const SizedBox(height: 24),

            // App info
            const Text('About', style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            _menuItem(FontAwesomeIcons.circleInfo, 'App Version', () {}, subtitle: '1.0.0'),
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
                  icon: const FaIcon(FontAwesomeIcons.rightFromBracket, color: Colors.redAccent, size: 18),
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

  Widget _themeOption(WidgetRef ref, String title, dynamic icon, AppThemeMode mode, AppThemeMode current) {
    final selected = current == mode;
    Widget iconWidget = const SizedBox.shrink();
    if (icon is FaIconData) {
      iconWidget = FaIcon(icon, color: selected ? AppTheme.gold : AppTheme.gray, size: 18);
    } else if (icon is IconData) {
      iconWidget = Icon(icon, color: selected ? AppTheme.gold : AppTheme.gray, size: 22);
    }

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
            SizedBox(width: 24, child: Center(child: iconWidget)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: selected ? AppTheme.gold : Colors.white, fontWeight: FontWeight.w600))),
            if (selected) const FaIcon(FontAwesomeIcons.circleCheck, color: AppTheme.gold, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(dynamic icon, String label, VoidCallback onTap, {String? subtitle}) {
    Widget iconWidget = const SizedBox.shrink();
    if (icon is FaIconData) {
      iconWidget = FaIcon(icon, color: AppTheme.gray, size: 18);
    } else if (icon is IconData) {
      iconWidget = Icon(icon, color: AppTheme.gray, size: 22);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            SizedBox(width: 24, child: Center(child: iconWidget)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            if (subtitle != null) Text(subtitle, style: const TextStyle(color: AppTheme.gray, fontSize: 13)),
            const SizedBox(width: 8),
            const FaIcon(FontAwesomeIcons.chevronRight, color: AppTheme.gray, size: 14),
          ],
        ),
      ),
    );
  }
}
