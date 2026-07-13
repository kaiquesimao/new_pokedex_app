import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/features/legal/presentation/legal_acceptance.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:pokedex_app/shared/widgets/trainer_illustration_group.dart';

class AuthWelcomePage extends ConsumerWidget {
  const AuthWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafePageBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: AppSurfaceTextButton(
                  onPressed: () async {
                    if (!await ensureLegalAccepted(context, ref)) return;
                    if (context.mounted) context.go('/pokedex');
                  },
                  icon: Icons.arrow_forward,
                  iconAlignment: IconAlignment.end,
                  label: l10n.authWelcomeSkipButton,
                ),
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
                    l10n.authWelcomeQuestion,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.authWelcomeSubtitle,
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
                      label: l10n.authWelcomeCreateAccount,
                      onPressed: () async {
                        if (!await ensureLegalAccepted(context, ref)) return;
                        if (context.mounted) await context.push('/register');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  AuthHubActionFrame(
                    child: AppSurfaceTextButton(
                      expand: true,
                      onPressed: () async {
                        if (!await ensureLegalAccepted(context, ref)) return;
                        if (context.mounted) await context.push('/login');
                      },
                      label: l10n.authWelcomeHaveAccount,
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
