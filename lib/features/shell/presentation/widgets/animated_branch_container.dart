import 'package:flutter/material.dart';

/// Animated container for [StatefulShellRoute] branch navigators.
///
/// Uses [IndexedStack] (same as go_router's default shell container) so branch
/// navigators stay mounted and [goBranch] can restore prior locations.
class AnimatedBranchContainer extends StatefulWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 450);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromRight = widget.currentIndex >= _previousIndex;
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    final slide = Tween<Offset>(
      begin: Offset(fromRight ? 0.14 : -0.14, 0),
      end: Offset.zero,
    ).animate(curved);

    final fade = Tween<double>(begin: 0.55, end: 1).animate(curved);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: IndexedStack(
          index: widget.currentIndex,
          sizing: StackFit.expand,
          children: [
            for (var index = 0; index < widget.children.length; index++)
              _BranchPane(
                isActive: index == widget.currentIndex,
                child: widget.children[index],
              ),
          ],
        ),
      ),
    );
  }
}

class _BranchPane extends StatelessWidget {
  const _BranchPane({required this.isActive, required this.child});

  final bool isActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !isActive,
      child: TickerMode(enabled: isActive, child: child),
    );
  }
}
