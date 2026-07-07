import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pokedex_app/core/constants/firebase_auth_config.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/legal/presentation/legal_acceptance.dart';
import 'package:pokedex_app/features/legal/presentation/providers/legal_acceptance_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class SocialSignInLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  bool get loading => state;

  set loading(bool value) => state = value;
}

final socialSignInLoadingProvider =
    NotifierProvider<SocialSignInLoadingNotifier, bool>(
      SocialSignInLoadingNotifier.new,
    );

class GoogleSignInUiErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  String? get report => state;

  set report(String? message) => state = message;

  void clear() => state = null;
}

final googleSignInUiErrorProvider =
    NotifierProvider<GoogleSignInUiErrorNotifier, String?>(
      GoogleSignInUiErrorNotifier.new,
    );

/// Wires GIS renderButton sign-in events to Firebase Auth on web.
final googleWebSignInSetupProvider = Provider<void>((ref) {
  if (!kIsWeb) return;

  final authNotifier = ref.read(authProvider.notifier);
  if (!authNotifier.usesFirebase) return;

  final subscription = GoogleSignIn.instance.authenticationEvents.listen(
    (event) async {
      if (event is! GoogleSignInAuthenticationEventSignIn) return;
      if (!ref.read(legalAcceptanceProvider) &&
          !ref.read(legalAcceptanceDraftProvider)) {
        // Use a message key; UI will resolve to localized string.
        ref.read(googleSignInUiErrorProvider.notifier).report =
            'authAcceptTerms';
        return;
      }

      ref.read(socialSignInLoadingProvider.notifier).loading = true;
      try {
        await ref.read(legalAcceptanceProvider.notifier).accept();
        await authNotifier.signInWithGoogleAccount(event.user);
      } on Object catch (e) {
        final l10n = lookupAppLocalizations(
          ref.read(appLocaleProvider).materialLocale,
        );
        ref.read(googleSignInUiErrorProvider.notifier).report =
            formatAuthException(l10n, e);
      } finally {
        ref.read(socialSignInLoadingProvider.notifier).loading = false;
      }
    },
    onError: (Object error) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      ref.read(googleSignInUiErrorProvider.notifier).report =
          formatAuthException(l10n, error);
    },
  );

  ref.onDispose(subscription.cancel);
  unawaited(FirebaseAuthConfig.ensureGoogleSignInInitialized());
});

Future<void> handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
  if (!await ensureLegalAccepted(context, ref)) return;
  if (!context.mounted) return;

  await _runSocialSignIn(
    context: context,
    ref: ref,
    action: () => ref.read(authProvider.notifier).signInWithGoogle(),
  );
}

Future<void> handleAppleSignIn(BuildContext context, WidgetRef ref) async {
  if (!await ensureLegalAccepted(context, ref)) return;
  if (!context.mounted) return;

  await _runSocialSignIn(
    context: context,
    ref: ref,
    action: () => ref.read(authProvider.notifier).signInWithApple(),
  );
}

Future<void> _runSocialSignIn({
  required BuildContext context,
  required WidgetRef ref,
  required Future<void> Function() action,
}) async {
  final notifier = ref.read(authProvider.notifier);
  if (!notifier.usesFirebase) {
    return;
  }

  ref.read(socialSignInLoadingProvider.notifier).loading = true;

  try {
    await action();
  } on Object catch (e) {
    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(formatAuthException(l10n, e))));
    }
  } finally {
    ref.read(socialSignInLoadingProvider.notifier).loading = false;
  }
}
