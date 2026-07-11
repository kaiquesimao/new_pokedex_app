import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/google_sign_in_web_scope.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/social_auth_actions.dart';
import 'package:pokedex_app/shared/widgets/social_auth_button.dart';

/// Google sign-in control: stable GIS button on web, custom pill on mobile.
class GoogleSignInActionButton extends ConsumerWidget {
  const GoogleSignInActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usesFirebase = ref.watch(authProvider.notifier).usesFirebase;
    if (!usesFirebase) {
      return const SizedBox.shrink();
    }

    if (kIsWeb) {
      return const GoogleSignInWebScope();
    }

    return SocialAuthButton(
      provider: SocialAuthProvider.google,
      onPressed: () => handleGoogleSignIn(context, ref),
    );
  }
}
