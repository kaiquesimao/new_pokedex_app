import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/game_text_resolver.dart';
import 'package:pokedex_app/core/locale/machine_translation_backend.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';

final machineTranslationBackendProvider = Provider<MachineTranslationBackend>(
  (ref) => InMemoryMachineTranslationBackend(),
);

final gameTextResolverProvider = Provider<GameTextResolver>((ref) {
  final remote = ref.watch(pokemonRemoteDataSourceProvider);

  Future<List<dynamic>> fetchEntries(ApiLoadTarget resource, String slug) {
    return switch (resource) {
      ApiLoadTarget.ability => remote.fetchAbility(slug).then(
        (json) => json['names'] as List<dynamic>? ?? [],
      ),
      ApiLoadTarget.eggGroup => remote.fetchEggGroup(slug).then(
        (json) => json['names'] as List<dynamic>? ?? [],
      ),
      ApiLoadTarget.item => remote.fetchItem(slug).then(
        (json) => json['names'] as List<dynamic>? ?? [],
      ),
      _ => Future.value([]),
    };
  }

  return GameTextResolver(
    machineTranslation: ref.watch(machineTranslationBackendProvider),
    fetchResourceEntries: fetchEntries,
  );
});
