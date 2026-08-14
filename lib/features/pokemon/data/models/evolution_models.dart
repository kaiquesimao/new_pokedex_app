import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';

class const EvolutionChainResponse({
  required final int id,
  required final ChainLinkResponse chain,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return EvolutionChainResponse(
      id: json['id'] as int? ?? 0,
      chain: ChainLinkResponse.fromJson(
        json['chain'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class const ChainLinkResponse({
  required final NamedApiResource species,
  required final List<ChainLinkResponse> evolvesTo,
  required final List<EvolutionDetailResponse> evolutionDetails,
}) {
  factory fromJson(Map<String, dynamic> json) {
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
}

class const EvolutionDetailResponse({
  final int? minLevel,
  final NamedApiResource? trigger,
  final NamedApiResource? item,
  final String? timeOfDay,
  final NamedApiResource? heldItem,
}) {
  factory fromJson(Map<String, dynamic> json) {
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
}
