import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';

class RegionCardData {
  const RegionCardData({
    required this.apiName,
    required this.displayName,
    required this.generationNumber,
    required this.gradientStart,
    required this.gradientEnd,
    required this.starterIds,
    this.landscapeAsset,
  });

  final String apiName;
  final String displayName;
  final int generationNumber;
  final Color gradientStart;
  final Color gradientEnd;
  final List<int> starterIds;
  final String? landscapeAsset;

  String generationLabel() => '$generationNumberª GERAÇÃO';
}

abstract final class RegionCardAssets {
  static const _landscapePath = 'assets/images/regions';

  static String starterSpriteUrl(int pokemonId) =>
      PokemonSpriteUrls.homeArtwork(pokemonId: pokemonId);

  static const List<RegionCardData> curated = [
    RegionCardData(
      apiName: 'kanto',
      displayName: 'Kanto',
      generationNumber: 1,
      gradientStart: Color(0xFF5B8C3E),
      gradientEnd: Color(0xFF2D4A22),
      starterIds: [1, 4, 7],
      landscapeAsset: '$_landscapePath/kanto.webp',
    ),
    RegionCardData(
      apiName: 'johto',
      displayName: 'Johto',
      generationNumber: 2,
      gradientStart: Color(0xFF8B6914),
      gradientEnd: Color(0xFF4A3A0F),
      starterIds: [152, 155, 158],
      landscapeAsset: '$_landscapePath/johto.webp',
    ),
    RegionCardData(
      apiName: 'hoenn',
      displayName: 'Hoenn',
      generationNumber: 3,
      gradientStart: Color(0xFF2E8B57),
      gradientEnd: Color(0xFF1A4D32),
      starterIds: [252, 255, 258],
      landscapeAsset: '$_landscapePath/hoenn.webp',
    ),
    RegionCardData(
      apiName: 'sinnoh',
      displayName: 'Sinnoh',
      generationNumber: 4,
      gradientStart: Color(0xFF6B8CAE),
      gradientEnd: Color(0xFF3A4F66),
      starterIds: [387, 390, 393],
      landscapeAsset: '$_landscapePath/sinnoh.webp',
    ),
    RegionCardData(
      apiName: 'unova',
      displayName: 'Unova',
      generationNumber: 5,
      gradientStart: Color(0xFF7B68EE),
      gradientEnd: Color(0xFF3D3477),
      starterIds: [495, 498, 501],
      landscapeAsset: '$_landscapePath/unova.webp',
    ),
    RegionCardData(
      apiName: 'kalos',
      displayName: 'Kalos',
      generationNumber: 6,
      gradientStart: Color(0xFFC71585),
      gradientEnd: Color(0xFF6B0F4A),
      starterIds: [650, 653, 656],
      landscapeAsset: '$_landscapePath/kalos.webp',
    ),
    RegionCardData(
      apiName: 'alola',
      displayName: 'Alola',
      generationNumber: 7,
      gradientStart: Color(0xFFFF8C00),
      gradientEnd: Color(0xFF994F00),
      starterIds: [722, 725, 728],
      landscapeAsset: '$_landscapePath/alola.webp',
    ),
    RegionCardData(
      apiName: 'galar',
      displayName: 'Galar',
      generationNumber: 8,
      gradientStart: Color(0xFF4169E1),
      gradientEnd: Color(0xFF1E3A8A),
      starterIds: [810, 813, 816],
      landscapeAsset: '$_landscapePath/galar.webp',
    ),
  ];

  static RegionCardData? forApiName(String apiName) {
    for (final region in curated) {
      if (region.apiName == apiName) return region;
    }
    return null;
  }

  static const Set<String> curatedApiNames = {
    'kanto',
    'johto',
    'hoenn',
    'sinnoh',
    'unova',
    'kalos',
    'alola',
    'galar',
  };
}
