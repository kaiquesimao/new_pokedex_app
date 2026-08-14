import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/auth_web_action_metrics.dart';

/// Centers auth actions on web with a shared fixed size.
class AuthHubActionFrame extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return Align(
      child: SizedBox(
        width: AuthWebActionMetrics.buttonWidth,
        height: AuthWebActionMetrics.buttonHeight,
        child: child,
      ),
    );
  }
}

/// Centers secondary auth links on web without forcing button height.
class AuthHubLinkFrame extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return Align(child: child);
  }
}

/// Centers auth forms and secondary actions on web at action button width.
class AuthHubNarrowFrame extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return Align(
      child: SizedBox(
        width: AuthWebActionMetrics.buttonWidth,
        child: child,
      ),
    );
  }
}
