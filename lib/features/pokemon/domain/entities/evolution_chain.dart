import 'package:pokedex_app/core/constants/pokemon_types.dart';

class EvolutionTriggerInfo {
  const EvolutionTriggerInfo({
    this.minLevel,
    this.trigger,
    this.item,
    this.timeOfDay,
    this.heldItem,
  });

  final int? minLevel;
  final String? trigger;
  final String? item;
  final String? timeOfDay;
  final String? heldItem;

  String get displayLabel {
    if (minLevel != null && minLevel! > 0) {
      return 'Nível $minLevel';
    }
    if (item != null && item!.isNotEmpty) {
      return _formatName(item!);
    }
    if (trigger == 'trade') return 'Troca';
    if (trigger == 'use-item') return 'Usar item';
    if (trigger == 'level-up') return 'Subir de nível';
    if (trigger == 'other') return 'Especial';
    if (timeOfDay != null && timeOfDay!.isNotEmpty) {
      return timeOfDay == 'day' ? 'Durante o dia' : 'À noite';
    }
    if (heldItem != null && heldItem!.isNotEmpty) {
      return 'Segurando ${_formatName(heldItem!)}';
    }
    return '';
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

class EvolutionChainNode {
  const EvolutionChainNode({
    required this.speciesId,
    required this.speciesName,
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
  final String? spriteUrl;
  final List<PokemonType> types;
  final EvolutionTriggerInfo? trigger;
  final List<EvolutionChainNode> evolvesTo;

  String get displayName => speciesName.isEmpty
      ? ''
      : speciesName[0].toUpperCase() + speciesName.substring(1);

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
