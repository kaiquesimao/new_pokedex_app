import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/theme/app_fonts.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_list_provider.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const splashDuration = Duration(milliseconds: 1200);

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  var _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrap());
    });
  }

  Future<void> _bootstrap() async {
    final authInit = ref.read(authProvider.notifier).initialize();
    final repository = ref.read(pokemonRepositoryProvider);
    final isOnline = ref.read(connectivityServiceProvider).isOnline;

    if (isOnline) {
      unawaited(repository.warmPokemonNameIndex());
    }

    unawaited(
      authInit.then((_) {
        if (!mounted) return;
        final auth = ref.read(authProvider);
        if (auth.isAuthenticated && isOnline) {
          ref.read(appDatabaseProvider);
          unawaited(ref.read(pokemonListProvider.notifier).loadInitial());
        }
      }),
    );

    await Future.wait<void>([
      authInit,
      Future<void>.delayed(SplashPage.splashDuration),
    ]);

    if (!mounted || _navigated) return;
    _navigated = true;

    final onboardingCompleted = ref.read(onboardingProvider);
    final auth = ref.read(authProvider);

    if (!onboardingCompleted) {
      context.go('/onboarding');
      return;
    }

    if (auth.isAuthenticated) {
      context.go('/pokedex');
      return;
    }

    context.go('/welcome');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final avatarSlug = ref.read(profileAvatarProvider);
    precacheImage(AssetImage(TrainerAvatars.assetPathFor(avatarSlug)), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsLight.splashNavy,
      body: SafePageBody(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: AppFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Poké',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'dex',
                      style: TextStyle(color: AppColorsLight.pokedexRed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
