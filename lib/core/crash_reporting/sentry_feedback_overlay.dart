import 'package:flutter/material.dart' as flutter_material;
import 'package:pokedex_app/core/crash_reporting/crash_reporting_enabled.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Flutter Material navigator used only for [SentryFeedbackForm].
///
/// The app shell uses `material_ui`, which is a separate Material library from
/// `package:flutter/material.dart` that Sentry's feedback widgets require.
/// This overlay hosts a real Flutter [flutter_material.MaterialApp] so the form
/// and the post-screenshot reopen path both work.
final flutter_material.GlobalKey<flutter_material.NavigatorState>
sentryFeedbackNavigatorKey =
    flutter_material.GlobalKey<flutter_material.NavigatorState>(
      debugLabel: 'sentry_feedback_navigator',
    );

/// Opens the Sentry feedback form on [sentryFeedbackNavigatorKey].
void openSentryFeedbackForm() {
  final context = sentryFeedbackNavigatorKey.currentContext;
  if (context == null || !context.mounted) {
    return;
  }
  SentryFeedbackForm.show(context);
}

/// Transparent Flutter Material layer for Sentry feedback routes.
///
/// Ignores pointers while idle so it does not block the app. When a feedback
/// route is pushed (or restored after a screenshot), it becomes interactive.
class SentryFeedbackOverlay extends flutter_material.StatefulWidget {
  // Flutter's analyzer flags the required private constructor name here.
  // ignore: unnecessary_type_name_in_constructor
  const SentryFeedbackOverlay({super.key});

  @override
  flutter_material.State<SentryFeedbackOverlay> createState() =>
      _SentryFeedbackOverlayState();
}

class _SentryFeedbackOverlayState
    extends flutter_material.State<SentryFeedbackOverlay> {
  /// Includes the MaterialApp home route; feedback pushes on top of it.
  var _routeDepth = 0;

  bool get _hasFeedbackRoute => _routeDepth > 1;

  @override
  flutter_material.Widget build(flutter_material.BuildContext context) {
    if (!isCrashReportingEnabled()) {
      return const flutter_material.SizedBox.shrink();
    }

    return flutter_material.IgnorePointer(
      ignoring: !_hasFeedbackRoute,
      child: flutter_material.Opacity(
        opacity: _hasFeedbackRoute ? 1 : 0,
        child: flutter_material.MaterialApp(
          navigatorKey: sentryFeedbackNavigatorKey,
          debugShowCheckedModeBanner: false,
          theme: flutter_material.ThemeData(
            useMaterial3: true,
            brightness: flutter_material.Brightness.light,
            scaffoldBackgroundColor: flutter_material.Colors.transparent,
          ),
          color: flutter_material.Colors.transparent,
          navigatorObservers: [
            _SentryFeedbackRouteDepthObserver(
              onDepthChanged: (depth) {
                if (!mounted || depth == _routeDepth) {
                  return;
                }
                setState(() => _routeDepth = depth);
              },
            ),
          ],
          home: const flutter_material.SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _SentryFeedbackRouteDepthObserver
    extends flutter_material.NavigatorObserver {
  // Flutter's analyzer flags the required private constructor name here.
  // ignore: unnecessary_type_name_in_constructor
  _SentryFeedbackRouteDepthObserver({required this.onDepthChanged});

  final void Function(int depth) onDepthChanged;
  var _depth = 0;

  void _emit() => onDepthChanged(_depth);

  @override
  void didPush(
    flutter_material.Route<dynamic> route,
    flutter_material.Route<dynamic>? previousRoute,
  ) {
    _depth += 1;
    _emit();
  }

  @override
  void didPop(
    flutter_material.Route<dynamic> route,
    flutter_material.Route<dynamic>? previousRoute,
  ) {
    if (_depth > 0) {
      _depth -= 1;
    }
    _emit();
  }

  @override
  void didRemove(
    flutter_material.Route<dynamic> route,
    flutter_material.Route<dynamic>? previousRoute,
  ) {
    if (_depth > 0) {
      _depth -= 1;
    }
    _emit();
  }

  @override
  void didReplace({
    flutter_material.Route<dynamic>? newRoute,
    flutter_material.Route<dynamic>? oldRoute,
  }) {
    _emit();
  }
}
