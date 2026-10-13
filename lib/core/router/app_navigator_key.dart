import 'package:material_ui/material_ui.dart';

/// Root navigator key used by GoRouter.
///
/// Sentry feedback uses a dedicated Flutter Material navigator — see
/// `sentryFeedbackNavigatorKey` in `sentry_feedback_overlay.dart`.
final GlobalKey<NavigatorState> appRootNavigatorKey =
    GlobalKey<NavigatorState>();
