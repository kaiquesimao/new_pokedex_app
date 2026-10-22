import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/whats_new/data/whats_new_changelog_loader.dart';

import '../support/memory_asset_bundle.dart';

void main() {
  test('asset path matches the Play changelog folders', () {
    expect(
      whatsNewChangelogAssetPath(localeTag: 'pt-BR', versionCode: 27),
      'store/google_play/pt-BR/changelogs/27.txt',
    );
  });

  test('prefers the interface locale and skips blank files', () async {
    final loader = WhatsNewChangelogLoader(
      bundle: MemoryAssetBundle({
        'store/google_play/pt-BR/changelogs/27.txt': '   ',
        'store/google_play/en-US/changelogs/27.txt': ' English notes ',
      }),
    );

    final body = await loader.loadBody(locale: AppLocale.pt, versionCode: 27);

    expect(body, 'English notes');
  });

  test('loads the bundled pt-BR notes for the current Play build', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final loader = WhatsNewChangelogLoader();

    final body = await loader.loadBody(locale: AppLocale.pt, versionCode: 27);

    expect(body, contains('Play Store'));
  });

  test('returns null when no locale has notes for the build', () async {
    final loader = WhatsNewChangelogLoader(bundle: MemoryAssetBundle({}));

    final body = await loader.loadBody(locale: AppLocale.en, versionCode: 99);

    expect(body, isNull);
  });
}
