import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/features/legal/presentation/legal_acceptance.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:pokedex_app/shared/widgets/trainer_illustration_group.dart';

class AuthWelcomePage extends ConsumerWidget {
  const AuthWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafePageBody(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  if (!await ensureLegalAccepted(context, ref)) return;
                  if (context.mounted) context.go('/pokedex');
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                iconAlignment: IconAlignment.end,
                label: const Text('Explorar sem conta'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TrainerIllustrationGroup(
                  imageAssets: [
                    TrainerAvatars.assetPathFor('miku'),
                    TrainerAvatars.assetPathFor('hilbert'),
                  ],
                  layout: TrainerIllustrationLayout.dual,
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
                  const SizedBox(height: 20),
                  const LegalAcceptanceField(),
                  const SizedBox(height: 16),
                  AuthHubActionFrame(
                    child: AppButton(
                      label: 'Criar conta',
                      onPressed: () async {
                        if (!await ensureLegalAccepted(context, ref)) return;
                        if (context.mounted) await context.push('/register');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  AuthHubLinkFrame(
                    child: TextButton(
                      onPressed: () async {
                        if (!await ensureLegalAccepted(context, ref)) return;
                        if (context.mounted) await context.push('/login');
                      },
                      child: Text(
                        'Já tenho uma conta',
                        style: TextStyle(
                          fontSize: kIsWeb ? 14 : null,
                          fontWeight: kIsWeb ? FontWeight.w600 : null,
                          color: theme.colorScheme.primary,
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
