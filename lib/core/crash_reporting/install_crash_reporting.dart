import 'package:flutter/foundation.dart';
import 'package:pokedex_app/core/crash_reporting/crash_platform.dart';
import 'package:pokedex_app/core/env/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Initializes Sentry (free Developer plan) for Android + web in one project.
///
/// No-ops when [Env.sentryDsn] is empty or in debug (keeps local noise out).
/// Filter issues in the Sentry UI by tags `app.platform` / `app.runtime`.
Future<void> installCrashReporting({
  required String appVersion,
  required String buildNumber,
  required Future<void> Function() appRunner,
}) async {
  final dsn = Env.sentryDsn.trim();
  if (dsn.isEmpty || kDebugMode) {
    await appRunner();
    return;
  }

  await SentryFlutter.init((options) {
    options
      ..dsn = dsn
      ..environment = kReleaseMode ? 'production' : 'profile'
      ..release = 'pokedex_app@$appVersion+$buildNumber'
      ..dist = buildNumber
      ..sendDefaultPii = false
      // Error monitoring only — keep free-tier quota for crashes, not tracing/replay.
      ..tracesSampleRate = 0;
  }, appRunner: () async {
    await Sentry.configureScope((scope) async {
      await scope.setTag('app.platform', resolveCrashPlatform());
      await scope.setTag('app.runtime', resolveCrashRuntime());
    });
    await appRunner();
  });
}
