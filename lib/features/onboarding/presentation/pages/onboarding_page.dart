import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:pokedex_app/shared/widgets/trainer_illustration_group.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  var _currentPage = 0;

  static const _pages = [
    _OnboardingSlide(
      imageAssets: [
        AppAssets.characterBugcatcher,
        AppAssets.characterBirch,
      ],
      title: 'Todos os Pokémon em um só Lugar',
      subtitle:
          'Acesse uma vasta lista de Pokémon de todas as gerações já '
          'feitas pela Nintendo',
    ),
    _OnboardingSlide(
      imageAssets: [AppAssets.characterHilda],
      title: 'Mantenha sua PokeData atualizada',
      subtitle:
          'Cadastre-se e mantenha seu perfil, Pokémon favoritos, '
          'configurações e muito mais, salvos no aplicativo, mesmo sem '
          'conexão com a internet.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).complete();
    if (mounted) context.go('/welcome');
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      unawaited(
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        ),
      );
      return;
    }
    unawaited(_finish());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafePageBody(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) {
                  final slide = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Expanded(
                          child: TrainerIllustrationGroup(
                            imageAssets: slide.imageAssets,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.catching_pokemon,
                              size: 120,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            _PageDots(count: _pages.length, current: _currentPage),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: AppButton(
                label: isLastPage ? 'Vamos começar!' : 'Continuar',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.imageAssets,
    required this.title,
    required this.subtitle,
  });

  final List<String> imageAssets;
  final String title;
  final String subtitle;
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor = primary.withValues(alpha: 0.25);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? primary : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
