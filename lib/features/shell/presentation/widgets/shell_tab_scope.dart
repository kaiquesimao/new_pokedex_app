import 'package:material_ui/material_ui.dart';

class const ShellTabScope({
  required final int currentIndex,
  required super.child,
  super.key,
}) extends InheritedWidget {
  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShellTabScope>();
    assert(scope != null, 'ShellTabScope not found in context');
    return scope!.currentIndex;
  }

  @override
  bool updateShouldNotify(ShellTabScope oldWidget) {
    return oldWidget.currentIndex != currentIndex;
  }
}

/// Defers building [child] until its tab is visited for the first time.
class const LazyShellTab({
  required final int tabIndex,
  required final Widget child,
  super.key,
}) extends StatefulWidget {
  @override
  State<LazyShellTab> createState() => _LazyShellTabState();
}

class _LazyShellTabState extends State<LazyShellTab> {
  var _activated = false;

  @override
  Widget build(BuildContext context) {
    final isActive = ShellTabScope.of(context) == widget.tabIndex;
    if (isActive) _activated = true;
    if (!_activated) return const SizedBox.shrink();
    return widget.child;
  }
}
