import 'package:pokedex_app/features/pokemon/data/models/evolution_models.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';

class EvolutionMapper {
  static EvolutionChainNode toNode(ChainLinkResponse link) {
    final trigger = link.evolutionDetails.isEmpty
        ? null
        : _mapTrigger(link.evolutionDetails.first);

    return EvolutionChainNode(
      speciesId: link.species.id,
      speciesName: link.species.name,
      trigger: trigger,
      evolvesTo: link.evolvesTo.map(toNode).toList(),
    );
  }

  static EvolutionTriggerInfo? _mapTrigger(EvolutionDetailResponse detail) {
    final hasData =
        detail.minLevel != null ||
        detail.trigger != null ||
        detail.item != null ||
        (detail.timeOfDay != null && detail.timeOfDay!.isNotEmpty) ||
        detail.heldItem != null;

    if (!hasData) return null;

    return EvolutionTriggerInfo(
      minLevel: detail.minLevel,
      trigger: detail.trigger?.name,
      item: detail.item?.name,
      timeOfDay: detail.timeOfDay,
      heldItem: detail.heldItem?.name,
    );
  }
}
