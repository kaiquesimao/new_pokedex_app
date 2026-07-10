import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';

void main() {
  const homeUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/25.png';
  const officialUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png';
  const lowResUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png';

  test('PokemonSprites prefers home then official then front_default', () {
    final parsed = PokemonSprites.fromJson({
      'front_default': lowResUrl,
      'other': {
        'official-artwork': {'front_default': officialUrl},
        'home': {'front_default': homeUrl},
      },
    });

    expect(parsed.displayUrl, homeUrl);
    expect(parsed.listUrl, lowResUrl);
  });

  test('PokemonSprites falls back when home is missing', () {
    final parsed = PokemonSprites.fromJson({
      'front_default': lowResUrl,
      'other': {
        'official-artwork': {'front_default': officialUrl},
      },
    });

    expect(parsed.displayUrl, officialUrl);
    expect(parsed.listUrl, lowResUrl);
  });

  test('officialArtworkFallbackFor maps home URLs to official artwork', () {
    expect(
      PokemonSpriteUrls.officialArtworkFallbackFor(homeUrl),
      officialUrl,
    );
    expect(
      PokemonSpriteUrls.officialArtworkFallbackFor(officialUrl),
      isNull,
    );
  });

  test('isLowResolutionSpriteUrl detects legacy list sprite URLs', () {
    expect(PokemonSpriteUrls.isLowResolutionSpriteUrl(lowResUrl), isTrue);
    expect(PokemonSpriteUrls.isLowResolutionSpriteUrl(homeUrl), isFalse);
    expect(PokemonSpriteUrls.isLowResolutionSpriteUrl(null), isFalse);
  });
}
