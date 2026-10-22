import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/whats_new/domain/whats_new_decision.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('decideWhatsNewPresentation', () {
    test('ignores a version that was already seen', () {
      expect(
        decideWhatsNewPresentation(
          lastSeenVersionCode: 27,
          currentVersionCode: 27,
          homeTutorialCompleted: true,
          hasChangelog: true,
        ),
        WhatsNewOutcome.ignore,
      );
    });

    test('ignores a newer stored code than the running build', () {
      expect(
        decideWhatsNewPresentation(
          lastSeenVersionCode: 28,
          currentVersionCode: 27,
          homeTutorialCompleted: true,
          hasChangelog: true,
        ),
        WhatsNewOutcome.ignore,
      );
    });

    test('records silently on the first session before the tutorial', () {
      expect(
        decideWhatsNewPresentation(
          lastSeenVersionCode: null,
          currentVersionCode: 27,
          homeTutorialCompleted: false,
          hasChangelog: true,
        ),
        WhatsNewOutcome.recordSilently,
      );
    });

    test('shows notes when a returning user has no stored code yet', () {
      expect(
        decideWhatsNewPresentation(
          lastSeenVersionCode: null,
          currentVersionCode: 27,
          homeTutorialCompleted: true,
          hasChangelog: true,
        ),
        WhatsNewOutcome.show,
      );
    });

    test('shows notes after a versionCode bump', () {
      expect(
        decideWhatsNewPresentation(
          lastSeenVersionCode: 26,
          currentVersionCode: 27,
          homeTutorialCompleted: false,
          hasChangelog: true,
        ),
        WhatsNewOutcome.show,
      );
    });

    test('records silently when the build has no changelog', () {
      expect(
        decideWhatsNewPresentation(
          lastSeenVersionCode: 26,
          currentVersionCode: 27,
          homeTutorialCompleted: true,
          hasChangelog: false,
        ),
        WhatsNewOutcome.recordSilently,
      );
    });
  });

  test('version code round-trips through SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    expect(readWhatsNewLastSeenVersionCode(prefs), isNull);

    await writeWhatsNewLastSeenVersionCode(prefs, 27);

    expect(readWhatsNewLastSeenVersionCode(prefs), 27);
  });
}
