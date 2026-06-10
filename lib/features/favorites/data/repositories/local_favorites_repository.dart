import 'dart:async';

import 'package:pokedex_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const favoritesStorageKey = 'favorite_pokemon_ids';

class LocalFavoritesRepository implements FavoritesRepository {
  LocalFavoritesRepository(this._prefs) : _cache = _readFromPrefs(_prefs) {
    _controller.add(_cache);
  }

  final SharedPreferences _prefs;
  final Set<int> _cache;
  final _controller = StreamController<Set<int>>.broadcast();

  static Set<int> _readFromPrefs(SharedPreferences prefs) {
    final ids = prefs.getStringList(favoritesStorageKey) ?? [];
    return ids.map(int.parse).toSet();
  }

  Future<void> _persist(Set<int> ids) async {
    await _prefs.setStringList(
      favoritesStorageKey,
      ids.map((e) => e.toString()).toList(),
    );
    _controller.add(ids);
  }

  @override
  Future<Set<int>> getFavoriteIds() async => Set<int>.from(_cache);

  @override
  Future<bool> isFavorite(int pokemonId) async => _cache.contains(pokemonId);

  Future<void> replaceAll(Set<int> ids) async {
    _cache
      ..clear()
      ..addAll(ids);
    await _persist(ids);
  }

  @override
  Future<void> toggleFavorite(int pokemonId) async {
    final updated = Set<int>.from(_cache);
    if (updated.contains(pokemonId)) {
      updated.remove(pokemonId);
    } else {
      updated.add(pokemonId);
    }
    _cache
      ..clear()
      ..addAll(updated);
    await _persist(updated);
  }

  @override
  Stream<Set<int>> watchFavoriteIds() => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
