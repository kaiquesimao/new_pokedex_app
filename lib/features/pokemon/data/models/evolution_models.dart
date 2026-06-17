import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';

class EvolutionChainResponse {
  const EvolutionChainResponse({required this.id, required this.chain});
  factory EvolutionChainResponse.fromJson(Map<String, dynamic> json) {
    return EvolutionChainResponse(
      id: json['id'] as int? ?? 0,
      chain: ChainLinkResponse.fromJson(
        json['chain'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  final int id;
  final ChainLinkResponse chain;
}

class ChainLinkResponse {
  const ChainLinkResponse({
    required this.species,
    required this.evolvesTo,
    required this.evolutionDetails,
  });
  factory ChainLinkResponse.fromJson(Map<String, dynamic> json) {
    return ChainLinkResponse(
      species: NamedApiResource.fromJson(
        json['species'] as Map<String, dynamic>? ?? {},
      ),
      evolvesTo: (json['evolves_to'] as List<dynamic>? ?? [])
          .map((e) => ChainLinkResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      evolutionDetails: (json['evolution_details'] as List<dynamic>? ?? [])
          .map(
            (e) => EvolutionDetailResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final NamedApiResource species;
  final List<ChainLinkResponse> evolvesTo;
  final List<EvolutionDetailResponse> evolutionDetails;
}

class EvolutionDetailResponse {
  const EvolutionDetailResponse({
    this.minLevel,
    this.trigger,
    this.item,
    this.timeOfDay,
    this.heldItem,
  });
  factory EvolutionDetailResponse.fromJson(Map<String, dynamic> json) {
    return EvolutionDetailResponse(
      minLevel: json['min_level'] as int?,
      trigger: json['trigger'] == null
          ? null
          : NamedApiResource.fromJson(json['trigger'] as Map<String, dynamic>),
      item: json['item'] == null
          ? null
          : NamedApiResource.fromJson(json['item'] as Map<String, dynamic>),
      timeOfDay: json['time_of_day'] as String?,
      heldItem: json['held_item'] == null
          ? null
          : NamedApiResource.fromJson(
              json['held_item'] as Map<String, dynamic>,
            ),
    );
  }

  final int? minLevel;
  final NamedApiResource? trigger;
  final NamedApiResource? item;
  final String? timeOfDay;
  final NamedApiResource? heldItem;
}
