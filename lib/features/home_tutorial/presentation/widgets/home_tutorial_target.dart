import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/home_tutorial/domain/home_tutorial_step.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/providers/home_tutorial_provider.dart';

/// Registers [child] as the spotlight target for [step].
class const HomeTutorialTarget({
  required final HomeTutorialStepId step,
  required final Widget child,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetKey = ref.watch(homeTutorialKeysProvider).keyFor(step);
    return KeyedSubtree(key: targetKey, child: child);
  }
}
