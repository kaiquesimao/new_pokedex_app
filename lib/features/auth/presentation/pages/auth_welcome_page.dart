import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class AuthWelcomePage extends StatelessWidget {
  const AuthWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafePageBody(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.go('/pokedex'),
                icon: const Icon(Icons.arrow_forward, size: 18),
                iconAlignment: IconAlignment.end,
                label: const Text('Pular'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: _WelcomeCharacterIllustration(
                    imageAssets: [
                      TrainerAvatars.assetPathFor('miku'),
                      TrainerAvatars.assetPathFor('hilbert'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Está pronto para essa aventura?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Basta criar uma conta e começar a explorar o mundo dos Pokémon hoje!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  AuthHubActionFrame(
                    child: AppButton(
                      label: 'Criar conta',
                      onPressed: () => context.push('/register'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AuthHubLinkFrame(
                    child: TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text(
                        'Já tenho uma conta',
                        style: TextStyle(
                          fontSize: kIsWeb ? 14 : null,
                          fontWeight: kIsWeb ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCharacterIllustration extends StatelessWidget {
  const _WelcomeCharacterIllustration({required this.imageAssets});

  final List<String> imageAssets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = (constraints.maxHeight * 0.9).clamp(200.0, 300.0);
        final slotWidth = constraints.maxWidth / imageAssets.length;
        final shadowWidth = kIsWeb ? 500.0 : constraints.maxWidth * 0.7;

        return SizedBox(
          height: imageHeight + 20,
          width: constraints.maxWidth,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: kIsWeb ? -10 : 50,
                child: Container(
                  width: shadowWidth,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < imageAssets.length; i++)
                      SizedBox(
                        width: slotWidth,
                        height: imageHeight,
                        child: Image.asset(
                          imageAssets[i],
                          fit: BoxFit.contain,
                          alignment: i == 0
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
