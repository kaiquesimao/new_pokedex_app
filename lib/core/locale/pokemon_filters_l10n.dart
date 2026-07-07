import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

String generationRomanNumeral(int id) => switch (id) {
  1 => 'I',
  2 => 'II',
  3 => 'III',
  4 => 'IV',
  5 => 'V',
  6 => 'VI',
  7 => 'VII',
  8 => 'VIII',
  9 => 'IX',
  _ => '$id',
};

extension PokemonSortOptionL10n on PokemonSortOption {
  String label(AppLocalizations l10n) => switch (this) {
    PokemonSortOption.numberAsc => l10n.sortNumberAsc,
    PokemonSortOption.numberDesc => l10n.sortNumberDesc,
    PokemonSortOption.nameAsc => l10n.sortNameAsc,
    PokemonSortOption.nameDesc => l10n.sortNameDesc,
  };
}

extension PokemonHeightBucketL10n on PokemonHeightBucket {
  String label(AppLocalizations l10n) => switch (this) {
    PokemonHeightBucket.small => l10n.heightBucketSmall,
    PokemonHeightBucket.medium => l10n.heightBucketMedium,
    PokemonHeightBucket.large => l10n.heightBucketLarge,
  };
}

extension PokemonWeightBucketL10n on PokemonWeightBucket {
  String label(AppLocalizations l10n) => switch (this) {
    PokemonWeightBucket.light => l10n.weightBucketLight,
    PokemonWeightBucket.medium => l10n.weightBucketMedium,
    PokemonWeightBucket.heavy => l10n.weightBucketHeavy,
  };
}

extension GenerationL10n on AppLocalizations {
  String generationPickerLabel(int id) =>
      generationPicker(generationRomanNumeral(id));

  String generationFallbackLabel(int id) => generationFallback(id);

  String regionGenerationBadgeLabel(int generationNumber) {
    final roman = generationRomanNumeral(generationNumber);
    return switch (localeName) {
      'pt' => regionGenerationBadgePt(generationNumber),
      _ => regionGenerationBadgeEn(roman),
    };
  }
}
