import 'package:flutter/material.dart';
import 'package:pokedex_app/features/shell/presentation/pages/main_shell_page.dart'
    show MainShellPage;

/// Wraps a [Scaffold] body with [SafeArea] insets.
///
/// Use [SafePageBody.belowAppBar] when the scaffold has an [AppBar] (top inset
/// is already handled by the app bar). Use [SafePageBody.inTabShell] for tab
/// pages inside [MainShellPage] (bottom inset handled by the navigation bar).
class SafePageBody extends StatelessWidget {
  const SafePageBody({
    required this.child,
    super.key,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  const SafePageBody.belowAppBar({
    required this.child,
    super.key,
    this.bottom = true,
    this.left = true,
    this.right = true,
  }) : top = false;

  const SafePageBody.inTabShell({
    required this.child,
    super.key,
    this.left = true,
    this.right = true,
  }) : top = false,
       bottom = false;

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

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
