import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/responsive_layout.dart';

/// Centers page content and caps its width on large viewports.
class ResponsiveContentFrame extends StatelessWidget {
  const ResponsiveContentFrame({
    required this.child,
    super.key,
    this.maxWidth = ResponsiveLayout.maxContentWidth,
    this.expandHeight = false,
  });

  final Widget child;
  final double maxWidth;

  /// When true, the child fills the vertical space (shell body). Leave false
  /// for compact children such as the bottom navigation bar.
  final bool expandHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) {
          return child;
        }

        final height = expandHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : null;

        return Row(
          children: [
            const Spacer(),
            SizedBox(
              width: maxWidth,
              height: height,
              child: child,
            ),
            const Spacer(),
          ],
        );
      },
    );
  }
}
