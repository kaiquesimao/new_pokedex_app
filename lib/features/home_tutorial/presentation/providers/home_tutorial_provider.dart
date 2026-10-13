import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/home_tutorial/domain/home_tutorial_step.dart';
import 'package:shared_preferences/shared_preferences.dart';

const homeTutorialCompletedKey = 'home_tutorial_completed';

bool readHomeTutorialCompleted(SharedPreferences prefs) {
  return prefs.getBool(homeTutorialCompletedKey) ?? false;
}

class const HomeTutorialState({
  required final bool completed,
  final bool isActive = false,
  final int stepIndex = 0,
}) {
  HomeTutorialStepId get currentStep =>
      HomeTutorialStepId.values[stepIndex.clamp(
        0,
        HomeTutorialStepId.values.length - 1,
      )];

  bool get isLastStep => stepIndex >= HomeTutorialStepId.values.length - 1;

  HomeTutorialState copyWith({
    bool? completed,
    bool? isActive,
    int? stepIndex,
  }) {
    return HomeTutorialState(
      completed: completed ?? this.completed,
      isActive: isActive ?? this.isActive,
      stepIndex: stepIndex ?? this.stepIndex,
    );
  }
}

class HomeTutorialNotifier extends Notifier<HomeTutorialState> {
  @override
  HomeTutorialState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return HomeTutorialState(completed: readHomeTutorialCompleted(prefs));
  }

  /// Starts the tour on first home visit when not yet completed.
  void tryAutoStart() {
    if (state.completed || state.isActive) return;
    state = state.copyWith(isActive: true, stepIndex: 0);
  }

  Future<void> next() async {
    if (!state.isActive) return;
    if (state.isLastStep) {
      await complete();
      return;
    }
    state = state.copyWith(stepIndex: state.stepIndex + 1);
  }

  Future<void> skip() => complete();

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(homeTutorialCompletedKey, true);
    state = const HomeTutorialState(completed: true);
  }

  /// Clears the completed flag and starts the tour again (Help → replay).
  Future<void> replay() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(homeTutorialCompletedKey, false);
    state = const HomeTutorialState(
      completed: false,
      isActive: true,
    );
  }
}

final homeTutorialProvider =
    NotifierProvider<HomeTutorialNotifier, HomeTutorialState>(
      HomeTutorialNotifier.new,
    );

/// Stable [GlobalKey]s for coach-mark targets (app lifetime while watched).
class HomeTutorialKeys {
  final Map<HomeTutorialStepId, GlobalKey> _keys = {
    for (final id in HomeTutorialStepId.values)
      id: GlobalKey(debugLabel: id.name),
  };

  GlobalKey keyFor(HomeTutorialStepId id) => _keys[id]!;
}

final homeTutorialKeysProvider = Provider<HomeTutorialKeys>((ref) {
  return HomeTutorialKeys();
});
