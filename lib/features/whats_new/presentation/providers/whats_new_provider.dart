import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/whats_new/data/whats_new_changelog_loader.dart';
import 'package:pokedex_app/features/whats_new/domain/whats_new_decision.dart';
import 'package:pokedex_app/features/whats_new/domain/whats_new_prompt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WhatsNewCoordinator {
  new({required this._prefs, required this._loader});

  final SharedPreferences _prefs;
  final WhatsNewChangelogLoader _loader;

  /// Returns the sheet content when this version should be announced.
  ///
  /// Persists [currentVersionCode] for [WhatsNewOutcome.show] and
  /// [WhatsNewOutcome.recordSilently] so the same build is not asked again.
  Future<WhatsNewPrompt?> resolve({
    required int currentVersionCode,
    required String versionName,
    required AppLocale locale,
    required bool homeTutorialCompleted,
  }) async {
    final lastSeen = readWhatsNewLastSeenVersionCode(_prefs);
    final body = await _loader.loadBody(
      locale: locale,
      versionCode: currentVersionCode,
    );
    final outcome = decideWhatsNewPresentation(
      lastSeenVersionCode: lastSeen,
      currentVersionCode: currentVersionCode,
      homeTutorialCompleted: homeTutorialCompleted,
      hasChangelog: body != null,
    );

    switch (outcome) {
      case WhatsNewOutcome.ignore:
        return null;
      case WhatsNewOutcome.recordSilently:
        await writeWhatsNewLastSeenVersionCode(_prefs, currentVersionCode);
        return null;
      case WhatsNewOutcome.show:
        await writeWhatsNewLastSeenVersionCode(_prefs, currentVersionCode);
        return WhatsNewPrompt(versionName: versionName, body: body!);
    }
  }
}

final whatsNewChangelogLoaderProvider = Provider<WhatsNewChangelogLoader>(
  (ref) => WhatsNewChangelogLoader(),
);

final whatsNewCoordinatorProvider = Provider<WhatsNewCoordinator>((ref) {
  return WhatsNewCoordinator(
    prefs: ref.watch(sharedPreferencesProvider),
    loader: ref.watch(whatsNewChangelogLoaderProvider),
  );
});
