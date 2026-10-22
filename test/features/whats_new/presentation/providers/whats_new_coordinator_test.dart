import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/whats_new/data/whats_new_changelog_loader.dart';
import 'package:pokedex_app/features/whats_new/domain/whats_new_decision.dart';
import 'package:pokedex_app/features/whats_new/presentation/providers/whats_new_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/memory_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const notes = 'Novidades desta versão.';

  WhatsNewCoordinator coordinatorFor(SharedPreferences prefs) {
    return WhatsNewCoordinator(
      prefs: prefs,
      loader: WhatsNewChangelogLoader(
        bundle: MemoryAssetBundle({
          'store/google_play/pt-BR/changelogs/27.txt': notes,
        }),
      ),
    );
  }

  test('shows once for a returning user and then stays quiet', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final coordinator = coordinatorFor(prefs);

    final first = await coordinator.resolve(
      currentVersionCode: 27,
      versionName: '1.6.12',
      locale: AppLocale.pt,
      homeTutorialCompleted: true,
    );
    final second = await coordinator.resolve(
      currentVersionCode: 27,
      versionName: '1.6.12',
      locale: AppLocale.pt,
      homeTutorialCompleted: true,
    );

    expect(first?.body, notes);
    expect(first?.versionName, '1.6.12');
    expect(second, isNull);
    expect(readWhatsNewLastSeenVersionCode(prefs), 27);
  });

  test('skips the sheet on a first session and does not show later', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final coordinator = coordinatorFor(prefs);

    final first = await coordinator.resolve(
      currentVersionCode: 27,
      versionName: '1.6.12',
      locale: AppLocale.pt,
      homeTutorialCompleted: false,
    );
    final later = await coordinator.resolve(
      currentVersionCode: 27,
      versionName: '1.6.12',
      locale: AppLocale.pt,
      homeTutorialCompleted: true,
    );

    expect(first, isNull);
    expect(later, isNull);
    expect(readWhatsNewLastSeenVersionCode(prefs), 27);
  });

  test('shows after a stored versionCode increases', () async {
    SharedPreferences.setMockInitialValues({
      whatsNewLastSeenVersionCodeKey: 26,
    });
    final prefs = await SharedPreferences.getInstance();
    final coordinator = coordinatorFor(prefs);

    final prompt = await coordinator.resolve(
      currentVersionCode: 27,
      versionName: '1.6.12',
      locale: AppLocale.pt,
      homeTutorialCompleted: true,
    );

    expect(prompt?.body, notes);
    expect(readWhatsNewLastSeenVersionCode(prefs), 27);
  });

  test('records the build when the changelog asset is missing', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final coordinator = WhatsNewCoordinator(
      prefs: prefs,
      loader: WhatsNewChangelogLoader(bundle: MemoryAssetBundle({})),
    );

    final prompt = await coordinator.resolve(
      currentVersionCode: 27,
      versionName: '1.6.12',
      locale: AppLocale.en,
      homeTutorialCompleted: true,
    );

    expect(prompt, isNull);
    expect(readWhatsNewLastSeenVersionCode(prefs), 27);
  });
}
