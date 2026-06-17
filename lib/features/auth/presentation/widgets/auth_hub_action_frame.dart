import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/auth_web_action_metrics.dart';

/// Centers auth actions on web with a shared fixed size.
class AuthHubActionFrame extends StatelessWidget {
  const AuthHubActionFrame({required this.child, super.key});

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
  const AuthHubLinkFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return Align(child: child);
  }
}
