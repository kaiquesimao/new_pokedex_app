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
  required Future<void> Function() appRunner,
}) async {
  if (!isCrashReportingEnabled()) {
    await appRunner();
    return;
  }

  final dsn = Env.sentryDsn.trim();

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = dsn
        ..environment = kReleaseMode ? 'production' : 'profile'
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

      // Bug reports use [BugReportPage] with gallery attachments.
      options.feedback.showCaptureScreenshot = false;

      options.addInAppInclude('package:pokedex_app');
    },
    appRunner: () async {
      await Sentry.configureScope((scope) async {
        await scope.setTag('app.platform', resolveCrashPlatform());
        await scope.setTag('app.runtime', resolveCrashRuntime());
      });

      Sentry.logger.info(
        'Sentry ready',
        attributes: {
          'app.platform': SentryAttribute.string(resolveCrashPlatform()),
          'app.runtime': SentryAttribute.string(resolveCrashRuntime()),
        },
      );

      await appRunner();
    },
  );
}

/// Attaches the store version after the Flutter binding exists.
///
/// Package info needs the binding, and on web that binding has to be created
/// inside Sentry's zone. Release is applied here, before runApp, so later
/// events still carry pokedex_app@version+build.
Future<void> bindCrashReportingAppIdentity({
  required String appVersion,
  required String buildNumber,
}) async {
  if (!Sentry.isEnabled) return;

  // Release is stored on the hub options. The SDK does not expose a public
  // setter after init, and init runs before package info is available.
  // ignore: invalid_use_of_internal_member
  Sentry.currentHub.options
    ..release = 'pokedex_app@$appVersion+$buildNumber'
    ..dist = buildNumber;

  await Sentry.configureScope((scope) async {
    await scope.setTag('app.version', appVersion);
    await scope.setTag('app.build', buildNumber);
  });
}
