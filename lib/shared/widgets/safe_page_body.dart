import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/shell/presentation/pages/main_shell_page.dart'
    show MainShellPage;

/// Wraps a [Scaffold] body with [SafeArea] insets.
///
/// Use [SafePageBody.belowAppBar] when the scaffold has an [AppBar] (top inset
/// is already handled by the app bar). Use [SafePageBody.inTabShell] for tab
/// pages inside [MainShellPage] (bottom inset handled by the navigation bar).
class const SafePageBody({
  required final Widget child,
  super.key,
  final bool top = true,
  final bool bottom = true,
  final bool left = true,
  final bool right = true,
}) extends StatelessWidget {
  const new belowAppBar({
    required Widget child,
    Key? key,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) : this(
         key: key,
         child: child,
         top: false,
         bottom: bottom,
         left: left,
         right: right,
       );

  const new inTabShell({
    required Widget child,
    Key? key,
    bool left = true,
    bool right = true,
  }) : this(
         key: key,
         child: child,
         top: false,
         bottom: false,
         left: left,
         right: right,
       );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}
