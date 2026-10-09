import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pokedex_app/app.dart';
import 'package:pokedex_app/core/bootstrap/app_bootstrap.dart';
import 'package:pokedex_app/core/bootstrap/firebase_config_error_app.dart';
import 'package:pokedex_app/core/crash_reporting/crash_reporting_enabled.dart';
import 'package:pokedex_app/core/crash_reporting/install_crash_reporting.dart';
import 'package:pokedex_app/core/logging/browser_console_bridge.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (kDebugMode && kIsWeb) {
    installBrowserConsoleBridge();
    // Prefer dart.tool.dart2wasm over identical(NaN, NaN) (Flutter Wasm docs).
    developer.log(
      'Web compiler: '
      '${const bool.fromEnvironment('dart.tool.dart2wasm') ? 'dart2wasm' : 'dart2js'}',
      name: 'flutter.web',
    );
  }

  final packageInfo = await PackageInfo.fromPlatform();
  final sentryEnabled = isCrashReportingEnabled();

  await installCrashReporting(
    appVersion: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
    appRunner: () async {
      final coldStart = await runColdStart();

      FlutterNativeSplash.remove();

      if (coldStart.firebaseConfigError) {
        runApp(const FirebaseConfigErrorApp());
        return;
      }

      Widget app = const PokedexApp();
      if (sentryEnabled) {
        // SentryWidget enables screenshots + user-interaction breadcrumbs/tracing.
        app = SentryWidget(child: app);
      }

      runApp(
        UncontrolledProviderScope(
          container: coldStart.container,
          child: app,
        ),
      );
    },
  );
}
