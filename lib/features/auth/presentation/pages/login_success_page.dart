import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:pokedex_app/shared/widgets/trainer_illustration_group.dart';

class LoginSuccessPage extends ConsumerWidget {
  const LoginSuccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (!auth.isAuthenticated) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final name = auth.displayName ?? 'Treinador';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !context.mounted) return;
        context.go('/pokedex');
      },
      child: Scaffold(
        body: SafePageBody(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          bottom: 8,
                          child: Container(
                            width: 220,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        TrainerIllustrationGroup(
                          imageAssets: [
                            TrainerAvatars.assetPathFor('blue'),
                            TrainerAvatars.assetPathFor('cynthia'),
                          ],
                          layout: TrainerIllustrationLayout.dual,
                        ),
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
                      'Bem-vindo de volta, $name!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Esperamos que tenha tido uma longa jornada desde a '
                      'última vez em que nos visitou.',
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
                        label: 'Continuar',
                        onPressed: () => context.go('/pokedex'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
