import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_layout.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_navigation_listener.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/google_sign_in_action_button.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/social_auth_actions.dart';
import 'package:pokedex_app/features/legal/presentation/legal_acceptance.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/social_auth_button.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenPostLoginNavigation(ref, postLoginRoute: '/register/success');
    final loading = ref.watch(socialSignInLoadingProvider);
    final usesFirebase = ref.watch(authProvider.notifier).usesFirebase;
    final canProceed = canProceedWithLegal(ref);

    final actions = <Widget>[
      if (usesFirebase)
        _gatedAction(
          canProceed: canProceed,
          child: const GoogleSignInActionButton(),
        ),
      _gatedAction(
        canProceed: canProceed,
        child: SocialAuthButton(
          provider: SocialAuthProvider.email,
          onPressed: () async {
            if (!await ensureLegalAccepted(context, ref)) return;
            ref.read(registerFlowProvider.notifier).reset();
            if (context.mounted) unawaited(context.push('/register/email'));
          },
        ),
      ),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        AuthHubLayout(
          appBarTitle: 'Criar conta',
          illustrationAsset: TrainerAvatars.assetPathFor('wallace_gen6'),
          headline: 'Falta pouco para explorar esse mundo!',
          subtitle: 'Como deseja se conectar?',
          footer: const LegalAcceptanceField(),
          actions: actions,
        ),
        if (loading)
          const Positioned.fill(
            child: AuthLoadingOverlay(message: 'Entrando...'),
          ),
      ],
    );
  }
}

Widget _gatedAction({required bool canProceed, required Widget child}) {
  return IgnorePointer(
    ignoring: !canProceed,
    child: Opacity(
      opacity: canProceed ? 1 : 0.45,
      child: child,
    ),
  );
}
