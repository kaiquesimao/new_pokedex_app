import 'package:flutter/foundation.dart';
import 'package:pokedex_app/core/env/env.dart';

/// Whether the Sentry SDK is active for this process.
///
/// Off in debug and when [Env.sentryDsn] is empty (quota-friendly local runs).
bool isCrashReportingEnabled() =>
    Env.sentryDsn.trim().isNotEmpty && !kDebugMode;
