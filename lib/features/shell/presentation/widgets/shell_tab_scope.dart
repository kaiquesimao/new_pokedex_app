import 'package:flutter/material.dart';

class ShellTabScope extends InheritedWidget {
  const ShellTabScope({
    required this.currentIndex,
    required super.child,
    super.key,
  });

  final int currentIndex;

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
class LazyShellTab extends StatefulWidget {
  const LazyShellTab({required this.tabIndex, required this.child, super.key});

  final int tabIndex;
  final Widget child;

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
