import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';

/// Catalog visibility for mega evolutions and alternate Pokémon forms.
class PokemonFormVisibility {
  const PokemonFormVisibility({
    this.showMegaEvolutions = true,
    this.showOtherForms = true,
  });

  final bool showMegaEvolutions;
  final bool showOtherForms;

  bool includesSummary(PokemonSummary summary) => includesSummaryNamed(
    summary: summary,
    showMegaEvolutions: showMegaEvolutions,
    showOtherForms: showOtherForms,
  );

  bool includes(String apiName) => includesNamed(
    apiName: apiName,
    showMegaEvolutions: showMegaEvolutions,
    showOtherForms: showOtherForms,
  );

  static bool includesSummaryNamed({
    required PokemonSummary summary,
    required bool showMegaEvolutions,
    required bool showOtherForms,
  }) {
    if (summary.isDefault != null) {
      return includesFlags(
        isDefault: summary.isDefault!,
        isMega: summary.isMega,
        showMegaEvolutions: showMegaEvolutions,
        showOtherForms: showOtherForms,
      );
    }

    return includesNamed(
      apiName: summary.name,
      showMegaEvolutions: showMegaEvolutions,
      showOtherForms: showOtherForms,
    );
  }

  static bool includesNamed({
    required String apiName,
    required bool showMegaEvolutions,
    required bool showOtherForms,
  }) {
    if (!showMegaEvolutions && isMegaForm(apiName)) return false;
    if (!showOtherForms && isAlternateForm(apiName)) return false;
    return true;
  }

  static bool includesFlags({
    required bool isDefault,
    required bool isMega,
    required bool showMegaEvolutions,
    required bool showOtherForms,
  }) {
    if (isDefault) return true;
    if (!showMegaEvolutions && isMega) return false;
    if (!showOtherForms && !isMega) return false;
    return true;
  }

  static bool isMegaForm(String apiName) =>
      RegExp(r'-mega(?:-|$)').hasMatch(apiName);

  /// Regional suffixes shared across an evolution line (PokeAPI `varieties`).
  static const regionalFormSuffixes = ['alola', 'galar', 'hisui', 'paldea'];

  /// Regional suffix shared across an evolution line (e.g. `grimer-alola` → `alola`).
  static String? regionalFormKey(String apiName) {
    if (isMegaForm(apiName)) return null;

    for (final region in regionalFormSuffixes) {
      if (apiName.endsWith('-$region')) return region;
    }
    return null;
  }

  static bool isRegionalForm(String apiName) =>
      regionalFormKey(apiName) != null;

  /// PokeAPI region name when it maps to a regional variety suffix (`hisui` → `*-hisui`).
  static String? regionalFormKeyForRegion(String regionApiName) {
    if (regionalFormSuffixes.contains(regionApiName)) return regionApiName;
    return null;
  }

  /// ponytail: name fallback when `is_default` / `is_mega` are not cached yet.
  static bool isAlternateForm(String apiName) {
    if (isMegaForm(apiName)) return false;

    if (isRegionalForm(apiName)) return true;

    if (apiName.contains('-gmax') ||
        apiName.contains('-totem') ||
        apiName.contains('-battle-bond') ||
        apiName.contains('-eternamax')) {
      return true;
    }

    if (apiName.startsWith('pikachu-') || apiName.startsWith('zygarde-')) {
      return true;
    }

    return false;
  }
}
