import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/theme_provider.dart';
import 'package:pokedex_app/core/router/app_router.dart';
import 'package:pokedex_app/core/theme/app_theme.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_session_effects_provider.dart';
import 'package:pokedex_app/shared/widgets/offline_banner.dart';

class PokedexApp extends ConsumerWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authSessionEffectsProvider);
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Pokédex',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => AppOfflineShell(child: child),
    );
  }
}
