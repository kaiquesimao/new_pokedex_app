import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/support/support_prompt_policy.dart';

void main() {
  group('SupportPromptPolicy', () {
    test('localDayKey uses local calendar yyyy-MM-dd', () {
      final key = SupportPromptPolicy.localDayKey(
        DateTime.utc(2026, 10, 22, 23, 30),
      );
      expect(key, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('canShowToday is true when never shown', () {
      expect(
        SupportPromptPolicy.canShowToday(
          lastShownDayKey: null,
          now: DateTime(2026, 10, 22, 15),
        ),
        isTrue,
      );
    });

    test('canShowToday is false on the same local day', () {
      final now = DateTime(2026, 10, 22, 18);
      expect(
        SupportPromptPolicy.canShowToday(
          lastShownDayKey: SupportPromptPolicy.localDayKey(now),
          now: now,
        ),
        isFalse,
      );
    });

    test('canShowToday is true on the next local day', () {
      expect(
        SupportPromptPolicy.canShowToday(
          lastShownDayKey: '2026-10-21',
          now: DateTime(2026, 10, 22, 1),
        ),
        isTrue,
      );
    });

    test('pastStartupGrace respects the 60s window', () {
      final started = DateTime(2026, 10, 22, 12);
      expect(
        SupportPromptPolicy.pastStartupGrace(
          startedAt: started,
          now: started.add(const Duration(seconds: 59)),
        ),
        isFalse,
      );
      expect(
        SupportPromptPolicy.pastStartupGrace(
          startedAt: started,
          now: started.add(const Duration(seconds: 60)),
        ),
        isTrue,
      );
    });

    test('favorite trigger is only the 2nd favorite', () {
      expect(SupportPromptPolicy.shouldPromptAfterFavoriteCount(1), isFalse);
      expect(SupportPromptPolicy.shouldPromptAfterFavoriteCount(2), isTrue);
      expect(SupportPromptPolicy.shouldPromptAfterFavoriteCount(3), isFalse);
    });

    test('detail trigger is only the 5th session open', () {
      expect(SupportPromptPolicy.shouldPromptAfterDetailOpen(4), isFalse);
      expect(SupportPromptPolicy.shouldPromptAfterDetailOpen(5), isTrue);
      expect(SupportPromptPolicy.shouldPromptAfterDetailOpen(6), isFalse);
    });

    test('game streak triggers when the 3rd correct lands', () {
      // Support prompt (POK-41): streak of 3 correct in a row; wrong ends
      // the session and resets score, so score == streak length.
      expect(
        SupportPromptPolicy.shouldPromptAfterGameStreak(
          answerCorrect: true,
          scoreBeforeAnswer: 2,
        ),
        isTrue,
      );
      expect(
        SupportPromptPolicy.shouldPromptAfterGameStreak(
          answerCorrect: true,
          scoreBeforeAnswer: 1,
        ),
        isFalse,
      );
      expect(
        SupportPromptPolicy.shouldPromptAfterGameStreak(
          answerCorrect: false,
          scoreBeforeAnswer: 2,
        ),
        isFalse,
      );
    });
  });
}
