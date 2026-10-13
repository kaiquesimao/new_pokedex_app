import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/providers/home_tutorial_provider.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/widgets/home_tutorial_overlay.dart';

/// Wraps the main shell and auto-starts the home tutorial once.
class const HomeTutorialHost({
  required final Widget child,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeTutorialHost> createState() => _HomeTutorialHostState();
}

class _HomeTutorialHostState extends ConsumerState<HomeTutorialHost> {
  Timer? _autoStartTimer;
  var _didScheduleAutoStart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleAutoStart());
  }

  @override
  void dispose() {
    _autoStartTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoStart() {
    if (_didScheduleAutoStart || !mounted) return;
    _didScheduleAutoStart = true;

    // Wait for list header / nav layout before measuring targets.
    _autoStartTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      ref.read(homeTutorialProvider.notifier).tryAutoStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isActive = ref.watch(
      homeTutorialProvider.select((s) => s.isActive),
    );

    // Keep keys alive for the shell lifetime.
    ref.watch(homeTutorialKeysProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (isActive) const HomeTutorialOverlay(),
      ],
    );
  }
}
