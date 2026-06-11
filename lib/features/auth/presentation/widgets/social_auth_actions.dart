import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_layout.dart';

final socialSignInLoadingProvider = StateProvider<bool>((ref) => false);

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

  ref.read(socialSignInLoadingProvider.notifier).state = true;

  try {
    await action();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(formatAuthException(e))));
    }
  } finally {
    ref.read(socialSignInLoadingProvider.notifier).state = false;
  }
}
