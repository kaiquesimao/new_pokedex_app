import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/providers/home_tutorial_provider.dart';
import 'package:pokedex_app/features/whats_new/data/whats_new_changelog_loader.dart';
import 'package:pokedex_app/features/whats_new/domain/whats_new_decision.dart';
import 'package:pokedex_app/features/whats_new/presentation/providers/whats_new_provider.dart';
import 'package:pokedex_app/features/whats_new/presentation/widgets/whats_new_host.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/l10n_test_helper.dart';
import '../../support/memory_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const changelog = 'Notas da versão de teste.';

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  testWidgets('shows the sheet for a returning user on a new build', (
    tester,
  ) async {
    final prefs = await prefsWith({homeTutorialCompletedKey: true});

    await pumpLocalizedApp(
      tester,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        packageInfoProvider.overrideWith(
          (ref) async => PackageInfo(
            appName: 'PokeData',
            packageName: 'com.kaiquesimao.pokedex',
            version: '1.6.12',
            buildNumber: '27',
          ),
        ),
        whatsNewChangelogLoaderProvider.overrideWithValue(
          WhatsNewChangelogLoader(
            bundle: MemoryAssetBundle({
              'store/google_play/pt-BR/changelogs/27.txt': changelog,
            }),
          ),
        ),
      ],
      child: const WhatsNewHost(child: SizedBox.shrink()),
    );
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text(changelog), findsOneWidget);
    expect(find.text('O que há de novo'), findsOneWidget);
    expect(readWhatsNewLastSeenVersionCode(prefs), 27);
  });

  testWidgets('does not show the sheet during the first home session', (
    tester,
  ) async {
    final prefs = await prefsWith({});

    await pumpLocalizedApp(
      tester,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        packageInfoProvider.overrideWith(
          (ref) async => PackageInfo(
            appName: 'PokeData',
            packageName: 'com.kaiquesimao.pokedex',
            version: '1.6.12',
            buildNumber: '27',
          ),
        ),
        whatsNewChangelogLoaderProvider.overrideWithValue(
          WhatsNewChangelogLoader(
            bundle: MemoryAssetBundle({
              'store/google_play/pt-BR/changelogs/27.txt': changelog,
            }),
          ),
        ),
      ],
      child: const WhatsNewHost(child: SizedBox.shrink()),
    );
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text(changelog), findsNothing);
    expect(readWhatsNewLastSeenVersionCode(prefs), 27);
  });
}
