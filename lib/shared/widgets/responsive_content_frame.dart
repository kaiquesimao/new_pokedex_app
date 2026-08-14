import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/responsive_layout.dart';

/// Centers page content and caps its width on large viewports.
class const ResponsiveContentFrame({
  required final Widget child,
  super.key,
  final double maxWidth = ResponsiveLayout.maxContentWidth,

  /// When true, the child fills the vertical space (shell body). Leave false
  /// for compact children such as the bottom navigation bar.
  final bool expandHeight = false,
}) extends StatelessWidget {
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
