import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_form_visibility.dart';

/// Stable label keys for detail sprite carousel items.
abstract final class PokemonSpriteVariantLabelKeys {
  static const normal = 'normal';
  static const shiny = 'shiny';
  static const mega = 'mega';
  static const megaX = 'mega-x';
  static const megaY = 'mega-y';
  static const alola = 'alola';
  static const galar = 'galar';
  static const hisui = 'hisui';
  static const paldea = 'paldea';
  static const gigantamax = 'gigantamax';
}

/// Derives carousel label keys from PokeAPI form names.
abstract final class PokemonSpriteVariantLabels {
  static String keyForSummary(PokemonSummary summary) {
    if (summary.isDefault == true) {
      return PokemonSpriteVariantLabelKeys.normal;
    }
    return keyForApiName(
      summary.slug.isNotEmpty ? summary.slug : summary.name,
      isMega: summary.isMega,
    );
  }

  static String keyForApiName(String apiName, {bool isMega = false}) {
    final normalized = apiName.toLowerCase();
    if (normalized.contains('-mega-x')) {
      return PokemonSpriteVariantLabelKeys.megaX;
    }
    if (normalized.contains('-mega-y')) {
      return PokemonSpriteVariantLabelKeys.megaY;
    }
    if (isMega || PokemonFormVisibility.isMegaForm(normalized)) {
      return PokemonSpriteVariantLabelKeys.mega;
    }

    final regional = PokemonFormVisibility.regionalFormKey(normalized);
    if (regional != null) return regional;

    if (normalized.contains('-gmax')) {
      return PokemonSpriteVariantLabelKeys.gigantamax;
    }

    final dash = normalized.indexOf('-');
    if (dash == -1 || dash == normalized.length - 1) {
      return PokemonSpriteVariantLabelKeys.normal;
    }
    return 'fallback:${normalized.substring(dash + 1)}';
  }

  static String titleCaseFallback(String labelKey) {
    final raw = labelKey.startsWith('fallback:')
        ? labelKey.substring('fallback:'.length)
        : labelKey;
    return raw
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
