import 'package:pokedex_app/core/env/env.dart';

/// Whether the Sentry SDK is active for this process.
///
/// Off when [Env.sentryDsn] is empty (quota-friendly local runs without a DSN).
/// Debug builds with a DSN stay enabled so Help → bug report can be tested
/// locally (including Flutter web).
bool isCrashReportingEnabled() => Env.sentryDsn.trim().isNotEmpty;
