import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/auth_web_action_metrics.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/google_sign_in_web_render.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/social_auth_actions.dart';
import 'package:pokedex_app/shared/widgets/social_auth_button.dart';

/// Google sign-in control: official GIS button on web, custom pill on mobile.
class GoogleSignInActionButton extends ConsumerWidget {
  const GoogleSignInActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..watch(googleWebSignInSetupProvider)
      ..listen(googleSignInUiErrorProvider, (previous, next) {
        if (next == null || !context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next)));
        ref.read(googleSignInUiErrorProvider.notifier).clear();
      });

    final usesFirebase = ref.watch(authProvider.notifier).usesFirebase;
    if (!usesFirebase) {
      return const SizedBox.shrink();
    }

    if (kIsWeb) {
      return buildGoogleSignInRenderButton(
        width: AuthWebActionMetrics.buttonWidth,
      );
    }

    return SocialAuthButton(
      provider: SocialAuthProvider.google,
      onPressed: () => handleGoogleSignIn(context, ref),
    );
  }
}
