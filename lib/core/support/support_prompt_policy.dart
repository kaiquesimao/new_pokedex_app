/// Shared rules for opportunistic Ko-fi support prompts (POK-41).
///
/// Surprise modals share one global daily cooldown. Profile / About / empty-
/// favorites soft CTAs ignore the cooldown (user-initiated).
abstract final class SupportPromptPolicy {
  static const lastShownDateKey = 'support_prompt_last_shown_date';
  static const startupGrace = Duration(seconds: 60);
  static const detailOpensBeforePrompt = 5;
  static const favoriteCountTrigger = 2;

  /// Game rule: prompt after a streak of 3 correct answers in a row.
  /// Wrong answers end the session and reset score, so score == streak.
  static const gameCorrectStreakTrigger = 3;

  /// Local calendar day as `yyyy-MM-dd` (device timezone).
  static String localDayKey(DateTime date) {
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static bool canShowToday({
    required String? lastShownDayKey,
    required DateTime now,
  }) {
    if (lastShownDayKey == null || lastShownDayKey.isEmpty) return true;
    return lastShownDayKey != localDayKey(now);
  }

  static bool pastStartupGrace({
    required DateTime startedAt,
    required DateTime now,
  }) {
    return !now.isBefore(startedAt.add(startupGrace));
  }

  static bool shouldPromptAfterFavoriteCount(int favoriteCountAfterAdd) =>
      favoriteCountAfterAdd == favoriteCountTrigger;

  static bool shouldPromptAfterDetailOpen(int sessionDetailOpenCount) =>
      sessionDetailOpenCount == detailOpensBeforePrompt;

  /// [scoreBeforeAnswer] is the session score when the correct answer is
  /// revealed (not yet incremented). Prompt when this correct answer makes
  /// the streak reach [gameCorrectStreakTrigger].
  static bool shouldPromptAfterGameStreak({
    required bool answerCorrect,
    required int scoreBeforeAnswer,
  }) {
    return answerCorrect &&
        scoreBeforeAnswer + 1 == gameCorrectStreakTrigger;
  }
}
