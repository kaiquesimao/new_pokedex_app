import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_layout.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/social_auth_actions.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/social_auth_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(socialSignInLoadingProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        AuthHubLayout(
          appBarTitle: 'Entrar',
          illustrationAsset: TrainerAvatars.assetPathFor('hilbert'),
          headline: 'Que bom te ver aqui novamente!',
          subtitle: 'Como deseja se conectar?',
          actions: [
            SocialAuthButton(
              provider: SocialAuthProvider.apple,
              onPressed: () => handleAppleSignIn(context, ref),
            ),
            SocialAuthButton(
              provider: SocialAuthProvider.google,
              onPressed: () => handleGoogleSignIn(context, ref),
            ),
            SocialAuthButton(
              provider: SocialAuthProvider.email,
              onPressed: () => context.push('/login/email'),
            ),
          ],
        ),
        if (loading)
          const Positioned.fill(
            child: AuthLoadingOverlay(message: 'Entrando...'),
          ),
      ],
    );
  }
}
