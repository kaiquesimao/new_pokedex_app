import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuessThePokemonLocalDataSource {
  new(this._prefs, {this.scopeKey = 'guest'});

  static const sessionKey = 'guess_the_pokemon_session';
  static const publicationKey = 'guess_the_pokemon_publication';
  static const bestScoreKey = 'guess_the_pokemon_best_score';
  static const publicProfileKey = 'guess_the_pokemon_public_profile';

  final SharedPreferences _prefs;
  final String scopeKey;

  String _scopedKey(String key) => '$key:$scopeKey';

  Future<int> getBestScore() async => _prefs.getInt(_scopedKey(bestScoreKey)) ?? 0;

  Future<void> saveBestScore(int score) async {
    await _prefs.setInt(_scopedKey(bestScoreKey), score);
  }

  Future<bool> getPublicProfilePreference() async =>
      _prefs.getBool(_scopedKey(publicProfileKey)) ?? false;

  Future<void> savePublicProfilePreference({required bool value}) async {
    await _prefs.setBool(_scopedKey(publicProfileKey), value);
  }

  Future<void> saveSession(GameSessionModel session) async {
    await _prefs.setString(_scopedKey(sessionKey), jsonEncode(session.toJson()));
  }

  Future<GameSessionModel?> readSession() async {
    final raw = _prefs.getString(_scopedKey(sessionKey));
    if (raw == null) return null;
    try {
      return GameSessionModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      return null;
    }
  }

  Future<void> savePublicationState(PublicationStateModel state) async {
    await _prefs.setString(_scopedKey(publicationKey), jsonEncode(state.toJson()));
  }

  Future<PublicationStateModel?> readPublicationState() async {
    final raw = _prefs.getString(_scopedKey(publicationKey));
    if (raw == null) return null;
    try {
      return PublicationStateModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      return null;
    }
  }

  Future<List<GameCatalogEntry>> loadCatalog() async {
    final raw = await rootBundle.loadString('assets/game/catalog-v1.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final entries = json['entries'];
    if (entries is! List) throw const FormatException('Invalid game catalog');
    return List.unmodifiable(entries.map((entry) {
      final value = entry as Map<String, dynamic>;
      final difficulty = switch (value['difficulty']) {
        'easy' => DifficultyBand.easy,
        'medium' => DifficultyBand.medium,
        'hard' => DifficultyBand.hard,
        _ => throw const FormatException('Invalid catalog difficulty'),
      };
      final id = value['id'];
      final name = value['label'];
      final spriteUrl = value['spriteUrl'];
      if (id is! int || name is! String || spriteUrl is! String ||
          spriteUrl.isEmpty) {
        throw const FormatException('Invalid catalog entry');
      }
      return GameCatalogEntry(
        speciesId: id,
        name: name,
        difficulty: difficulty,
        spriteUrl: spriteUrl,
      );
    }).cast<GameCatalogEntry>());
  }
}
