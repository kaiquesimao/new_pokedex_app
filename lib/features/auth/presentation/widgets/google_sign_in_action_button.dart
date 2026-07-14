import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/social_auth_actions.dart';
import 'package:pokedex_app/shared/widgets/social_auth_button.dart';

/// Google sign-in control (mobile only; hidden on web under Wasm COOP/COEP).
class GoogleSignInActionButton extends ConsumerWidget {
  const GoogleSignInActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    final usesFirebase = ref.watch(authProvider.notifier).usesFirebase;
    if (!usesFirebase) {
      return const SizedBox.shrink();
    }

    return SocialAuthButton(
      provider: SocialAuthProvider.google,
      onPressed: () => handleGoogleSignIn(context, ref),
    );
  }
}
