import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';

class GenerationResponse {
  const GenerationResponse({
    required this.id,
    required this.name,
    required this.pokemonSpecies,
  });
  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    return GenerationResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pokemonSpecies: (json['pokemon_species'] as List<dynamic>? ?? [])
          .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String name;
  final List<NamedApiResource> pokemonSpecies;
}

class TypeDamageRelations {
  const TypeDamageRelations({required this.doubleDamageTo});
  factory TypeDamageRelations.fromJson(Map<String, dynamic> json) {
    final to = json['double_damage_to'] as List<dynamic>? ?? [];
    return TypeDamageRelations(
      doubleDamageTo: to
          .map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }

  final List<String> doubleDamageTo;
}

class TypeResponse {
  const TypeResponse({
    required this.id,
    required this.name,
    required this.pokemon,
    required this.damageRelations,
  });
  factory TypeResponse.fromJson(Map<String, dynamic> json) {
    return TypeResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pokemon: (json['pokemon'] as List<dynamic>? ?? [])
          .map(
            (entry) => NamedApiResource.fromJson(
              (entry as Map<String, dynamic>)['pokemon']
                  as Map<String, dynamic>,
            ),
          )
          .toList(),
      damageRelations: TypeDamageRelations.fromJson(
        json['damage_relations'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  final int id;
  final String name;
  final List<NamedApiResource> pokemon;
  final TypeDamageRelations damageRelations;
}
