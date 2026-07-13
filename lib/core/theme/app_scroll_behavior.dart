import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Enables mouse/trackpad drag for [PageView] and other scrollables on web.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
