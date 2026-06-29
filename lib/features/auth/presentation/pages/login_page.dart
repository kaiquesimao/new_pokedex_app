import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_layout.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_navigation_listener.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/google_sign_in_action_button.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/social_auth_actions.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/social_auth_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenPostLoginNavigation(ref);
    final loading = ref.watch(socialSignInLoadingProvider);
    final usesFirebase = ref.watch(authProvider.notifier).usesFirebase;

    final actions = <Widget>[
      if (usesFirebase && defaultTargetPlatform == TargetPlatform.iOS)
        SocialAuthButton(
          provider: SocialAuthProvider.apple,
          onPressed: () => handleAppleSignIn(context, ref),
        ),
      if (usesFirebase) const GoogleSignInActionButton(),
      SocialAuthButton(
        provider: SocialAuthProvider.email,
        onPressed: () => context.push('/login/email'),
      ),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        AuthHubLayout(
          appBarTitle: 'Entrar',
          illustrationAsset: TrainerAvatars.assetPathFor('victor'),
          headline: 'Que bom te ver aqui novamente!',
          subtitle: 'Como deseja se conectar?',
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
