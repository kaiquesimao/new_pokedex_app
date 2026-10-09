import 'package:flutter/foundation.dart';
import 'package:pokedex_app/core/crash_reporting/crash_platform.dart';
import 'package:pokedex_app/core/crash_reporting/crash_reporting_enabled.dart';
import 'package:pokedex_app/core/crash_reporting/sentry_event_scrubber.dart';
import 'package:pokedex_app/core/env/env.dart';
import 'package:pokedex_app/core/router/app_navigator_key.dart';
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
  if (!isCrashReportingEnabled()) {
    await appRunner();
    return;
  }

  final dsn = Env.sentryDsn.trim();

  await SentryFlutter.init((options) {
    options
      ..dsn = dsn
      ..environment = kReleaseMode ? 'production' : 'profile'
      ..release = 'pokedex_app@$appVersion+$buildNumber'
      ..dist = buildNumber
      ..sendDefaultPii = false
      ..navigatorKey = appRootNavigatorKey
      ..maxBreadcrumbs = 100
      // Light performance sample — navigation/Dio/Drift spans without burning quota.
      ..tracesSampleRate = 0.15
      ..enableAutoPerformanceTracing = true
      ..enableAutoSessionTracking = true
      ..attachStacktrace = true
      ..reportSilentFlutterErrors = true
      ..captureFailedRequests = true
      ..enableUserInteractionBreadcrumbs = true
      ..enableUserInteractionTracing = true
      // Screenshots / view hierarchy: mobile & desktop UI only (masked by default).
      ..attachScreenshot = !kIsWeb
      ..attachViewHierarchy = !kIsWeb
      ..screenshotQuality = SentryScreenshotQuality.medium
      ..beforeSend = scrubSentryEvent
      ..beforeSendLog = (log, hint) {
        // Structured logs are on by default in v10; drop noisy levels.
        if (log.level == SentryLogLevel.debug ||
            log.level == SentryLogLevel.trace) {
          return null;
        }
        return log;
      };

    options.privacy
      ..maskAllText = true
      ..maskAllImages = true;

    options.feedback
      ..title = 'Report a Bug'
      ..formTitle = 'Report a Bug'
      ..showBranding = false
      ..useSentryUser = true
      ..isEmailRequired = false
      ..showEmail = true
      ..showName = true;

    options.addInAppInclude('package:pokedex_app');
  }, appRunner: () async {
    await Sentry.configureScope((scope) async {
      await scope.setTag('app.platform', resolveCrashPlatform());
      await scope.setTag('app.runtime', resolveCrashRuntime());
      await scope.setTag('app.version', appVersion);
      await scope.setTag('app.build', buildNumber);
    });

    Sentry.logger.info(
      'Sentry ready',
      attributes: {
        'app.platform': SentryAttribute.string(resolveCrashPlatform()),
        'app.runtime': SentryAttribute.string(resolveCrashRuntime()),
        'app.version': SentryAttribute.string(appVersion),
      },
    );

    await appRunner();
  });
}
