import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/support/support_prompt_dialog.dart';
import 'package:pokedex_app/core/support/support_prompt_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Coordinates surprise Ko-fi support modals (daily cooldown + session counts).
class SupportPromptController({
  required final SharedPreferences prefs,
  final DateTime Function()? clock,
  final DateTime? startedAt,
}) {
  final DateTime Function() _clock = clock ?? DateTime.now;
  late final DateTime _startedAt = startedAt ?? _clock();

  var _sessionDetailOpens = 0;
  var _dialogVisible = false;

  @visibleForTesting
  int get sessionDetailOpens => _sessionDetailOpens;

  /// Increments the session detail-open counter without showing UI.
  @visibleForTesting
  bool recordDetailOpen() {
    _sessionDetailOpens++;
    return SupportPromptPolicy.shouldPromptAfterDetailOpen(_sessionDetailOpens);
  }

  bool get canShowSurpriseToday {
    return SupportPromptPolicy.canShowToday(
      lastShownDayKey: prefs.getString(SupportPromptPolicy.lastShownDateKey),
      now: _clock(),
    );
  }

  bool get pastStartupGrace {
    return SupportPromptPolicy.pastStartupGrace(
      startedAt: _startedAt,
      now: _clock(),
    );
  }

  bool get _canOfferSurprise =>
      !_dialogVisible && canShowSurpriseToday && pastStartupGrace;

  /// User-initiated (Profile/About soft CTAs): always show, no cooldown.
  Future<void> showFromUserAction(BuildContext context) {
    return _present(context, markCooldown: false);
  }

  /// After adding a favorite; fires only on the 2nd favorite.
  Future<void> maybeAfterSecondFavorite(
    BuildContext context, {
    required int favoriteCountAfterAdd,
  }) async {
    if (!SupportPromptPolicy.shouldPromptAfterFavoriteCount(
      favoriteCountAfterAdd,
    )) {
      return;
    }
    await maybeShowSurprise(context);
  }

  /// Counts a Pokémon detail open; prompts on the 5th open this session.
  Future<void> onPokemonDetailOpened(BuildContext context) async {
    if (!recordDetailOpen()) return;
    await maybeShowSurprise(context);
  }

  /// Empty Favorites landing: auto-popup once if the daily cap allows.
  Future<void> maybeOnEmptyFavorites(BuildContext context) async {
    await maybeShowSurprise(context);
  }

  /// Who's That Pokémon: after a streak of 3 correct answers (see policy).
  Future<void> maybeAfterGameStreak(
    BuildContext context, {
    required bool answerCorrect,
    required int scoreBeforeAnswer,
  }) async {
    if (!SupportPromptPolicy.shouldPromptAfterGameStreak(
      answerCorrect: answerCorrect,
      scoreBeforeAnswer: scoreBeforeAnswer,
    )) {
      return;
    }
    // Let the round result / reveal UI settle before dimming the barrier.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!context.mounted) return;
    await maybeShowSurprise(context);
  }

  Future<void> maybeShowSurprise(BuildContext context) async {
    if (!_canOfferSurprise) return;
    await _present(context, markCooldown: true);
  }

  Future<void> _present(
    BuildContext context, {
    required bool markCooldown,
  }) async {
    if (!context.mounted || _dialogVisible) return;
    _dialogVisible = true;
    try {
      if (markCooldown) {
        await prefs.setString(
          SupportPromptPolicy.lastShownDateKey,
          SupportPromptPolicy.localDayKey(_clock()),
        );
      }
      if (!context.mounted) return;
      await showSupportPromptDialog(context);
    } finally {
      _dialogVisible = false;
    }
  }
}

final supportPromptControllerProvider = Provider<SupportPromptController>((
  ref,
) {
  return SupportPromptController(
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

/// Fire-and-forget helper for call sites that already hold a [BuildContext].
void scheduleSupportPrompt(
  Future<void> Function() action,
) {
  unawaited(action());
}
