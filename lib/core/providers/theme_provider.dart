import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { dark, light, system }

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _key = 'theme_mode';

  @override
  AppThemeMode build() {
    _load();
    return AppThemeMode.dark;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    state = AppThemeMode.values[index.clamp(0, 2)];
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }

  void toggle() {
    final next = state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
    setTheme(next);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(themeProvider);
  return switch (mode) {
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.system => ThemeMode.system,
  };
});
