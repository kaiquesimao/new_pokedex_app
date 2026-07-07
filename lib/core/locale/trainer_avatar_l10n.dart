import 'package:pokedex_app/l10n/generated/app_localizations.dart';

String trainerAvatarLabel(AppLocalizations l10n, String slug) {
  return switch (slug) {
    'bugcatcher' => l10n.trainerAvatarBugCatcherLabel,
    'pokemaniac' => l10n.trainerAvatarPokemaniacLabel,
    _ => slug,
  };
}
