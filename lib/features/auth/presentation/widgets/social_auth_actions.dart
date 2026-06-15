import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pokedex_app/core/constants/firebase_auth_config.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_layout.dart';

class SocialSignInLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) => state = value;
}

final socialSignInLoadingProvider =
    NotifierProvider<SocialSignInLoadingNotifier, bool>(
      SocialSignInLoadingNotifier.new,
    );

class GoogleSignInUiErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void report(String? message) => state = message;

  void clear() => state = null;
}

final googleSignInUiErrorProvider =
    NotifierProvider<GoogleSignInUiErrorNotifier, String?>(
      GoogleSignInUiErrorNotifier.new,
    );

/// Wires GIS [renderButton] sign-in events to Firebase Auth on web.
final googleWebSignInSetupProvider = Provider<void>((ref) {
  if (!kIsWeb) return;

  final authNotifier = ref.read(authProvider.notifier);
  if (!authNotifier.usesFirebase) return;

  final subscription = GoogleSignIn.instance.authenticationEvents.listen(
    (event) async {
      if (event is! GoogleSignInAuthenticationEventSignIn) return;

      ref.read(socialSignInLoadingProvider.notifier).setLoading(true);
      try {
        await authNotifier.signInWithGoogleAccount(event.user);
      } catch (e) {
        ref
            .read(googleSignInUiErrorProvider.notifier)
            .report(formatAuthException(e));
      } finally {
        ref.read(socialSignInLoadingProvider.notifier).setLoading(false);
      }
    },
    onError: (Object error) {
      ref
          .read(googleSignInUiErrorProvider.notifier)
          .report(formatAuthException(error));
    },
  );

  ref.onDispose(subscription.cancel);
  unawaited(FirebaseAuthConfig.ensureGoogleSignInInitialized());
});

Future<void> handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
  await _runSocialSignIn(
    context: context,
    ref: ref,
    providerName: 'Google',
    action: () => ref.read(authProvider.notifier).signInWithGoogle(),
  );
}

Future<void> handleAppleSignIn(BuildContext context, WidgetRef ref) async {
  await _runSocialSignIn(
    context: context,
    ref: ref,
    providerName: 'Apple',
    action: () => ref.read(authProvider.notifier).signInWithApple(),
  );
}

Future<void> _runSocialSignIn({
  required BuildContext context,
  required WidgetRef ref,
  required String providerName,
  required Future<void> Function() action,
}) async {
  final notifier = ref.read(authProvider.notifier);
  if (!notifier.usesFirebase) {
    showSocialAuthStubSnackBar(context, providerName);
    return;
  }

  ref.read(socialSignInLoadingProvider.notifier).setLoading(true);

  try {
    await action();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(formatAuthException(e))));
    }
  } finally {
    ref.read(socialSignInLoadingProvider.notifier).setLoading(false);
  }
}
