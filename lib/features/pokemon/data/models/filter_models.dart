import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';

class const GenerationResponse({
  required final int id,
  required final String name,
  required final List<NamedApiResource> pokemonSpecies,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return GenerationResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pokemonSpecies: (json['pokemon_species'] as List<dynamic>? ?? [])
          .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class const TypeDamageRelations({required final List<String> doubleDamageTo}) {
  factory fromJson(Map<String, dynamic> json) {
    final to = json['double_damage_to'] as List<dynamic>? ?? [];
    return TypeDamageRelations(
      doubleDamageTo: to
          .map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }
}

class const TypeResponse({
  required final int id,
  required final String name,
  required final List<NamedApiResource> pokemon,
  required final TypeDamageRelations damageRelations,
}) {
  factory fromJson(Map<String, dynamic> json) {
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
