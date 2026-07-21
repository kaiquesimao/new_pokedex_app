import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_form_visibility.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_sprite_variant_labels.dart';

/// Builds user-facing Pokémon names, including alternate forms.
///
/// PokeAPI species `names` are shared by all varieties (e.g. every Charizard
/// form is just "Charizard"). Form-aware labels are composed from the Pokémon
/// resource slug (`charizard-mega-x` → "Charizard Mega X").
abstract final class PokemonDisplayNames {
  static String resolve({
    required String apiName,
    String? speciesLocalizedName,
    bool? isDefault,
  }) {
    final normalized = apiName.trim().toLowerCase();
    if (normalized.isEmpty) {
      final species = speciesLocalizedName?.trim() ?? '';
      return species;
    }

    final base = _baseDisplayName(
      apiName: normalized,
      speciesLocalizedName: speciesLocalizedName,
    );

    final treatAsDefault = isDefault ?? !_looksLikeAlternateForm(normalized);
    if (treatAsDefault) return base;

    final formLabel = _formLabelFromApiName(normalized);
    if (formLabel.isEmpty) return base;
    return '$base $formLabel';
  }

  static String _baseDisplayName({
    required String apiName,
    String? speciesLocalizedName,
  }) {
    final species = speciesLocalizedName?.trim() ?? '';
    if (species.isNotEmpty) return species;

    final dash = apiName.indexOf('-');
    final baseSlug = dash == -1 ? apiName : apiName.substring(0, dash);
    return _titleCaseToken(baseSlug);
  }

  static String _formLabelFromApiName(String apiName) {
    final key = PokemonSpriteVariantLabels.keyForApiName(apiName);
    if (key == PokemonSpriteVariantLabelKeys.normal) return '';
    return PokemonSpriteVariantLabels.titleCaseFallback(key);
  }

  static bool _looksLikeAlternateForm(String apiName) {
    return PokemonFormVisibility.isMegaForm(apiName) ||
        PokemonFormVisibility.isAlternateForm(apiName);
  }

  static String _titleCaseToken(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
