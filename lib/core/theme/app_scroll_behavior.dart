import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// Enables mouse/trackpad drag for [PageView] and other scrollables on web.
class const AppScrollBehavior() extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
