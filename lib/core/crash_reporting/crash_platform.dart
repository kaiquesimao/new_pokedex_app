import 'package:flutter/foundation.dart';

/// Surface tag for filtering Android vs web (and future iOS) in Sentry.
String resolveCrashPlatform() {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'other',
  };
}

/// Compiler/runtime tag (`native`, `dart2wasm`, `dart2js`).
String resolveCrashRuntime() {
  if (!kIsWeb) return 'native';
  return const bool.fromEnvironment('dart.tool.dart2wasm')
      ? 'dart2wasm'
      : 'dart2js';
}
