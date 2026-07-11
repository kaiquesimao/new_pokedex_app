import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pokedex_app/core/constants/auth_web_action_metrics.dart';
import 'package:pokedex_app/core/constants/firebase_auth_config.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/google_sign_in_web_render.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/social_auth_actions.dart';
import 'package:pokedex_app/features/legal/presentation/providers/legal_acceptance_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/social_auth_button.dart';

/// One GIS iframe + one auth listener for the whole web app.
abstract final class GoogleSignInWebButtonHost {
  static Widget? button;
  static final ready = ValueNotifier<bool>(false);

  static Future<void>? _warming;
  static String? _localeTag;

  static Future<void> warm(String localeTag) {
    if (button != null && _localeTag == localeTag) {
      return Future<void>.value();
    }
    return _warming ??= _doWarm(localeTag);
  }

  static Future<void> _doWarm(String localeTag) async {
    try {
      await FirebaseAuthConfig.ensureGoogleSignInInitialized();
      if (button != null && _localeTag == localeTag) return;

      _localeTag = localeTag;
      button = RepaintBoundary(
        child: SizedBox(
          width: AuthWebActionMetrics.buttonWidth,
          height: AuthWebActionMetrics.buttonHeight,
          child: buildGoogleSignInRenderButton(
            width: AuthWebActionMetrics.buttonWidth,
            localeTag: localeTag,
          ),
        ),
      );
      ready.value = true;
    } finally {
      _warming = null;
    }
  }

  static Future<void> resetForLocale(String localeTag) {
    if (_localeTag == localeTag && button != null) {
      return Future<void>.value();
    }
    button = null;
    _localeTag = null;
    ready.value = false;
    return warm(localeTag);
  }
}

/// App-level GIS wiring: init once, single authenticationEvents listener.
final googleSignInWebHostProvider = Provider<void>((ref) {
  if (!kIsWeb) return;
  if (!ref.read(firebaseBootstrapProvider).isAvailable) return;

  StreamSubscription<GoogleSignInAuthenticationEvent>? subscription;
  ref.onDispose(() => unawaited(subscription?.cancel()));

  unawaited(
    FirebaseAuthConfig.ensureGoogleSignInInitialized().then((_) {
      subscription = GoogleSignIn.instance.authenticationEvents.listen(
        (event) => unawaited(_onGoogleSignInWebAuthEvent(ref, event)),
        onError: (Object error) => _onGoogleSignInWebAuthError(ref, error),
      );
      return GoogleSignInWebButtonHost.warm(ref.read(appLocaleProvider).tag);
    }),
  );

  ref.listen(appLocaleProvider, (previous, next) {
    if (previous?.tag == next.tag) return;
    unawaited(GoogleSignInWebButtonHost.resetForLocale(next.tag));
  });
});

Future<void> _onGoogleSignInWebAuthEvent(
  Ref ref,
  GoogleSignInAuthenticationEvent event,
) async {
  if (event is! GoogleSignInAuthenticationEventSignIn) return;
  if (!ref.read(legalAcceptanceProvider) &&
      !ref.read(legalAcceptanceDraftProvider)) {
    ref.read(googleSignInUiErrorProvider.notifier).report = 'authAcceptTerms';
    return;
  }

  ref.read(socialSignInLoadingProvider.notifier).loading = true;
  try {
    await ref.read(legalAcceptanceProvider.notifier).accept();
    await ref.read(authProvider.notifier).signInWithGoogleAccount(event.user);
  } on Object catch (e) {
    final l10n = lookupAppLocalizations(
      ref.read(appLocaleProvider).materialLocale,
    );
    ref.read(googleSignInUiErrorProvider.notifier).report = formatAuthException(
      l10n,
      e,
    );
  } finally {
    ref.read(socialSignInLoadingProvider.notifier).loading = false;
  }
}

void _onGoogleSignInWebAuthError(Ref ref, Object error) {
  final l10n = lookupAppLocalizations(
    ref.read(appLocaleProvider).materialLocale,
  );
  ref.read(googleSignInUiErrorProvider.notifier).report = formatAuthException(
    l10n,
    error,
  );
}

/// Displays the shared GIS button on auth pages.
class GoogleSignInWebScope extends ConsumerWidget {
  const GoogleSignInWebScope({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(googleSignInUiErrorProvider, (previous, next) {
      if (next == null || !context.mounted) return;
      final l10n = AppLocalizations.of(context);
      final message = next == 'authAcceptTerms'
          ? l10n.authLegalAcceptTerms
          : next;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      ref.read(googleSignInUiErrorProvider.notifier).clear();
    });

    return ValueListenableBuilder<bool>(
      valueListenable: GoogleSignInWebButtonHost.ready,
      builder: (context, isReady, _) {
        final button = GoogleSignInWebButtonHost.button;
        if (!isReady || button == null) {
          return const _GoogleSignInWebPlaceholder();
        }
        return button;
      },
    );
  }
}

class _GoogleSignInWebPlaceholder extends StatelessWidget {
  const _GoogleSignInWebPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SocialAuthButton(
        provider: SocialAuthProvider.google,
        onPressed: _noop,
      ),
    );
  }
}

void _noop() {}
