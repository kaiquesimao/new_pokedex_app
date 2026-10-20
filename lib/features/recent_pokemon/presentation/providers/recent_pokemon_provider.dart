import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/recent_pokemon/domain/recent_pokemon_history.dart';

class RecentPokemonNotifier extends Notifier<List<int>> {
  @override
  List<int> build() {
    return readRecentPokemonIds(ref.watch(sharedPreferencesProvider));
  }

  Future<void> record(int id) async {
    final next = pushRecentPokemonId(state, id);
    if (listEquals(state, next)) return;

    state = next;
    await _persist(next);
  }

  Future<void> clear() async {
    if (state.isEmpty) return;

    state = const [];
    await _persist(const []);
  }

  Future<void> _persist(List<int> ids) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (ids.isEmpty) {
      await prefs.remove(recentPokemonIdsKey);
      return;
    }

    await prefs.setStringList(
      recentPokemonIdsKey,
      ids.map((id) => id.toString()).toList(),
    );
  }
}

final recentPokemonProvider =
    NotifierProvider<RecentPokemonNotifier, List<int>>(
      RecentPokemonNotifier.new,
    );

/// Summaries in the same order as [recentPokemonProvider]. Failures become an
/// empty list so the home screen can keep rendering.
final recentPokemonSummariesProvider = FutureProvider<List<PokemonSummary>>((
  ref,
) async {
  final ids = ref.watch(recentPokemonProvider);
  if (ids.isEmpty) return const [];

  try {
    final summaries = await ref
        .read(pokemonRepositoryProvider)
        .getSummariesByIds(ids);
    return _orderSummariesByIds(ids, summaries);
  } on Object {
    return const [];
  }
});

List<PokemonSummary> _orderSummariesByIds(
  List<int> ids,
  List<PokemonSummary> summaries,
) {
  final byId = {for (final summary in summaries) summary.id: summary};
  final ordered = <PokemonSummary>[];
  for (final id in ids) {
    final summary = byId[id];
    if (summary != null) ordered.add(summary);
  }
  return ordered;
}
