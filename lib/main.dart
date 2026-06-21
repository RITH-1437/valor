import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ValorApp(),
    ),
  );
}

class ValorApp extends ConsumerWidget {
  const ValorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VALOR',
      theme: AppTheme.lightFashionTheme,
      darkTheme: AppTheme.fashionTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
