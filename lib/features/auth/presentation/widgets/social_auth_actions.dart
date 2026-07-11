import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/legal/presentation/legal_acceptance.dart';
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
