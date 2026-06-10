import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';

class GenerationResponse {
  const GenerationResponse({
    required this.id,
    required this.name,
    required this.pokemonSpecies,
  });

  final int id;
  final String name;
  final List<NamedApiResource> pokemonSpecies;

  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    return GenerationResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pokemonSpecies: (json['pokemon_species'] as List<dynamic>? ?? [])
          .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TypeDamageRelations {
  const TypeDamageRelations({required this.doubleDamageTo});

  final List<String> doubleDamageTo;

  factory TypeDamageRelations.fromJson(Map<String, dynamic> json) {
    final to = json['double_damage_to'] as List<dynamic>? ?? [];
    return TypeDamageRelations(
      doubleDamageTo: to
          .map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }
}

class TypeResponse {
  const TypeResponse({
    required this.id,
    required this.name,
    required this.pokemon,
    required this.damageRelations,
  });

  final int id;
  final String name;
  final List<NamedApiResource> pokemon;
  final TypeDamageRelations damageRelations;

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
}
