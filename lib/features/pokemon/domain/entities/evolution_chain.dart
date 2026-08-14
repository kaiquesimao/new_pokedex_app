import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class const EvolutionTriggerInfo({
  final int? minLevel,
  final String? trigger,
  final String? itemSlug,
  final String? itemDisplayName,
  final String? timeOfDay,
  final String? heldItemSlug,
  final String? heldItemDisplayName,
}) {
  String displayLabel(AppLocalizations l10n) {
    final level = minLevel;
    if (level != null && level > 0) {
      return l10n.evolutionTriggerLevel(level);
    }
    final itemName = itemDisplayName;
    if (itemName != null && itemName.isNotEmpty) return itemName;
    return switch (trigger) {
      'trade' => l10n.evolutionTriggerTrade,
      'use-item' => l10n.evolutionTriggerUseItem,
      'level-up' => l10n.evolutionTriggerLevelUp,
      'other' => l10n.evolutionTriggerOther,
      _ => switch (timeOfDay) {
        final String tod when tod.isNotEmpty =>
          tod == 'day'
              ? l10n.evolutionTriggerDuringDay
              : l10n.evolutionTriggerAtNight,
        _ => switch (heldItemDisplayName) {
          final String held when held.isNotEmpty =>
            l10n.evolutionTriggerHoldingItem(held),
          _ => '',
        },
      },
    };
  }
}

class const EvolutionChainNode({
  required final int? speciesId,
  required final String speciesName,
  final String? localizedDisplayName,
  final int? pokemonId,
  final String? spriteUrl,
  final List<PokemonType> types = const [],
  final EvolutionTriggerInfo? trigger,
  final List<EvolutionChainNode> evolvesTo = const [],
}) {
  String get displayName {
    final localized = localizedDisplayName;
    if (localized != null && localized.isNotEmpty) return localized;
    return speciesName.isEmpty
        ? ''
        : speciesName[0].toUpperCase() + speciesName.substring(1);
  }

  bool get hasEvolution => evolvesTo.isNotEmpty;
}

class const EvolutionChain({
  required final EvolutionChainNode root,
  required final int currentPokemonId,
  required final int currentSpeciesId,
}) {
  bool get isSingleStage => !root.hasEvolution;
}
