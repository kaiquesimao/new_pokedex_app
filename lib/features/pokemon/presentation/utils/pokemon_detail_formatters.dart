import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

abstract final class PokemonDetailFormatters {
  static String decimal(double value, AppLocale locale) {
    final fixed = value.toStringAsFixed(1);
    return locale == AppLocale.pt ? fixed.replaceAll('.', ',') : fixed;
  }

  static String statLabel(AppLocalizations l10n, String apiName) {
    return switch (apiName) {
      'hp' => l10n.statHp,
      'attack' => l10n.statAttack,
      'defense' => l10n.statDefense,
      'special-attack' => l10n.statSpecialAttack,
      'special-defense' => l10n.statSpecialDefense,
      'speed' => l10n.statSpeed,
      _ => _formatName(apiName),
    };
  }

  /// PokeAPI `gender_rate` uses steps of 12.5% (0–8), not 0–255.
  static double femalePercent(int genderRate) {
    if (genderRate <= 0) return 0;
    if (genderRate >= 8 || genderRate == 254) return 100;
    return genderRate * 12.5;
  }

  static double malePercent(int genderRate) => 100 - femalePercent(genderRate);

  static String genderLabel(
    AppLocalizations l10n,
    int genderRate,
    AppLocale locale,
  ) {
    if (genderRate < 0) return l10n.genderNone;
    if (genderRate == 0) return l10n.genderMaleOnly;
    if (genderRate >= 8 || genderRate == 254) return l10n.genderFemaleOnly;
    return l10n.genderFemalePercent(
      decimal(femalePercent(genderRate), locale),
    );
  }

  static String hatchSteps(AppLocalizations l10n, int hatchCounter) {
    if (hatchCounter <= 0) return l10n.hatchNever;
    return l10n.hatchSteps((hatchCounter * 255).toString());
  }

  static String _formatName(String value) {
    return value
        .split('-')
        .map((part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1);
        })
        .join(' ');
  }
}
