import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/auth_web_action_metrics.dart';

/// Centers auth actions on web with a shared fixed size.
class const AuthHubActionFrame({required final Widget child, super.key})
    extends StatelessWidget {
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
class const AuthHubLinkFrame({required final Widget child, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return Align(child: child);
  }
}

/// Centers auth forms and secondary actions on web at action button width.
class const AuthHubNarrowFrame({required final Widget child, super.key})
    extends StatelessWidget {
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
