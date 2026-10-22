import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/support/support_prompt_controller.dart';
import 'package:pokedex_app/core/support/support_prompt_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupportPromptController', () {
    late SharedPreferences prefs;
    late DateTime now;
    late SupportPromptController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      now = DateTime(2026, 10, 22, 15);
      controller = SupportPromptController(
        prefs: prefs,
        clock: () => now,
        startedAt: now.subtract(const Duration(minutes: 5)),
      );
    });

    test('canShowSurpriseToday flips when the day key is stored', () async {
      expect(controller.canShowSurpriseToday, isTrue);
      await prefs.setString(
        SupportPromptPolicy.lastShownDateKey,
        SupportPromptPolicy.localDayKey(now),
      );
      expect(controller.canShowSurpriseToday, isFalse);

      now = DateTime(2026, 10, 23, 9);
      expect(controller.canShowSurpriseToday, isTrue);
    });

    test('pastStartupGrace is false inside the first 60s', () {
      final young = SupportPromptController(
        prefs: prefs,
        clock: () => now,
        startedAt: now.subtract(const Duration(seconds: 30)),
      );
      expect(young.pastStartupGrace, isFalse);
      expect(controller.pastStartupGrace, isTrue);
    });

    test('recordDetailOpen triggers only on the 5th open', () {
      for (var i = 1; i <= 4; i++) {
        expect(controller.recordDetailOpen(), isFalse, reason: 'open $i');
      }
      expect(controller.recordDetailOpen(), isTrue, reason: 'open 5');
      expect(controller.recordDetailOpen(), isFalse, reason: 'open 6');
      expect(controller.sessionDetailOpens, 6);
    });
  });
}
