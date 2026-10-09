import 'dart:async' show FutureOr, unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/crash_reporting/crash_reporting_enabled.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/theme_provider.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void _unawaitScope(FutureOr<void> result) {
  if (result is Future<void>) {
    unawaited(result);
  }
}

/// Keeps Sentry user + tags in sync with auth, locale, theme, and connectivity.
///
/// Watch from the root app widget so the listeners stay alive for the app lifetime.
final sentryContextSyncProvider = Provider<void>((ref) {
  if (!isCrashReportingEnabled()) {
    return;
  }

  void applyAuth(AuthState auth) {
    final session = !auth.isInitialized
        ? 'uninitialized'
        : (auth.isAuthenticated ? 'authenticated' : 'guest');

    _unawaitScope(
      Sentry.configureScope((scope) async {
        await scope.setTag('auth.session', session);
        if (auth.isAuthenticated && auth.uid != null) {
          // uid only — never email (sendDefaultPii stays false).
          await scope.setUser(
            SentryUser(
              id: auth.uid,
              username: auth.displayName,
              data: {
                'email_verified': auth.emailVerified.toString(),
              },
            ),
          );
        } else {
          await scope.setUser(null);
        }
      }),
    );

    if (auth.isInitialized) {
      Sentry.logger.info(
        'Auth session: $session',
        attributes: {
          'auth.session': SentryAttribute.string(session),
          if (auth.uid != null) 'user_id': SentryAttribute.string(auth.uid!),
        },
      );
    }
  }

  applyAuth(ref.read(authProvider));
  ref
    ..listen<AuthState>(authProvider, (_, next) => applyAuth(next))
    ..listen<AppLocale>(appLocaleProvider, (_, next) {
      _unawaitScope(
        Sentry.configureScope((scope) async {
          await scope.setTag('app.locale', next.name);
        }),
      );
    })
    ..listen<ThemeMode>(themeModeProvider, (_, next) {
      _unawaitScope(
        Sentry.configureScope((scope) async {
          await scope.setTag('app.theme', next.name);
        }),
      );
    })
    ..listen<AsyncValue<bool>>(connectivityStatusProvider, (_, next) {
      final online = next.value;
      if (online == null) return;
      _unawaitScope(
        Sentry.configureScope((scope) async {
          await scope.setTag('network.online', online.toString());
        }),
      );
    });

  // Seed tags that may not fire a listen immediately.
  final locale = ref.read(appLocaleProvider);
  final theme = ref.read(themeModeProvider);
  final online = ref.read(isDeviceOnlineProvider);
  _unawaitScope(
    Sentry.configureScope((scope) async {
      await scope.setTag('app.locale', locale.name);
      await scope.setTag('app.theme', theme.name);
      await scope.setTag('network.online', online.toString());
    }),
  );
});
