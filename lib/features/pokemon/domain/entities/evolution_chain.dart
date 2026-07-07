import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class EvolutionTriggerInfo {
  const EvolutionTriggerInfo({
    this.minLevel,
    this.trigger,
    this.itemSlug,
    this.itemDisplayName,
    this.timeOfDay,
    this.heldItemSlug,
    this.heldItemDisplayName,
  });

  final int? minLevel;
  final String? trigger;
  final String? itemSlug;
  final String? itemDisplayName;
  final String? timeOfDay;
  final String? heldItemSlug;
  final String? heldItemDisplayName;

  String displayLabel(AppLocalizations l10n) {
    if (minLevel != null && minLevel! > 0) {
      return l10n.evolutionTriggerLevel(minLevel!);
    }
    if (itemDisplayName != null && itemDisplayName!.isNotEmpty) {
      return itemDisplayName!;
    }
    if (trigger == 'trade') return l10n.evolutionTriggerTrade;
    if (trigger == 'use-item') return l10n.evolutionTriggerUseItem;
    if (trigger == 'level-up') return l10n.evolutionTriggerLevelUp;
    if (trigger == 'other') return l10n.evolutionTriggerOther;
    if (timeOfDay != null && timeOfDay!.isNotEmpty) {
      return timeOfDay == 'day'
          ? l10n.evolutionTriggerDuringDay
          : l10n.evolutionTriggerAtNight;
    }
    if (heldItemDisplayName != null && heldItemDisplayName!.isNotEmpty) {
      return l10n.evolutionTriggerHoldingItem(heldItemDisplayName!);
    }
    return '';
  }
}

class EvolutionChainNode {
  const EvolutionChainNode({
    required this.speciesId,
    required this.speciesName,
    this.localizedDisplayName,
    this.pokemonId,
    this.spriteUrl,
    this.types = const [],
    this.trigger,
    this.evolvesTo = const [],
  });

  final int? speciesId;

  /// Pokémon entry id when this stage shows a specific form (e.g. mega).
  final int? pokemonId;
  final String speciesName;
  final String? localizedDisplayName;
  final String? spriteUrl;
  final List<PokemonType> types;
  final EvolutionTriggerInfo? trigger;
  final List<EvolutionChainNode> evolvesTo;

  String get displayName {
    if (localizedDisplayName != null && localizedDisplayName!.isNotEmpty) {
      return localizedDisplayName!;
    }
    return speciesName.isEmpty
        ? ''
        : speciesName[0].toUpperCase() + speciesName.substring(1);
  }

  bool get hasEvolution => evolvesTo.isNotEmpty;
}

class EvolutionChain {
  const EvolutionChain({
    required this.root,
    required this.currentPokemonId,
    required this.currentSpeciesId,
  });

  final EvolutionChainNode root;
  final int currentPokemonId;
  final int currentSpeciesId;

  bool get isSingleStage => !root.hasEvolution;
}
