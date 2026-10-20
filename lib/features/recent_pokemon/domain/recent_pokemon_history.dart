import 'package:shared_preferences/shared_preferences.dart';

const recentPokemonIdsKey = 'recent_pokemon_ids';

const recentPokemonHistoryLimit = 12;

/// Parses stored id strings. Drops non-positive and unparsable values, keeps
/// the first occurrence (most recent first), and caps at [recentPokemonHistoryLimit].
List<int> parseRecentPokemonIds(List<String>? raw) {
  if (raw == null || raw.isEmpty) return const [];

  final ids = <int>[];
  for (final value in raw) {
    final id = int.tryParse(value);
    if (id == null || id <= 0 || ids.contains(id)) continue;
    ids.add(id);
    if (ids.length >= recentPokemonHistoryLimit) break;
  }
  return ids;
}

List<int> readRecentPokemonIds(SharedPreferences prefs) {
  return parseRecentPokemonIds(prefs.getStringList(recentPokemonIdsKey));
}

/// Returns a new most-recent-first list, or [current] when [id] is ignored
/// or already at the front.
List<int> pushRecentPokemonId(List<int> current, int id) {
  if (id <= 0) return current;

  final next = <int>[id];
  for (final existing in current) {
    if (existing == id || existing <= 0) continue;
    next.add(existing);
    if (next.length >= recentPokemonHistoryLimit) break;
  }

  if (next.length == current.length) {
    for (var index = 0; index < next.length; index++) {
      if (next[index] != current[index]) return next;
    }
    return current;
  }
  return next;
}
