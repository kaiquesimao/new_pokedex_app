import 'package:flutter/foundation.dart';

/// Difficulty bands used to keep each round's options comparable.
enum DifficultyBand { easy, medium, hard }

/// Local catalog data required to build a guessing round.
@immutable
class const GameCatalogEntry({
  required final int speciesId,
  required final String name,
  required final DifficultyBand difficulty,
  final String? spriteUrl,
}) {
  @override
  bool operator ==(Object other) =>
      other is GameCatalogEntry &&
      other.speciesId == speciesId &&
      other.name == name &&
      other.difficulty == difficulty &&
      other.spriteUrl == spriteUrl;

  @override
  int get hashCode => Object.hash(speciesId, name, difficulty, spriteUrl);
}
