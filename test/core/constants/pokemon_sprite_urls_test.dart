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

  test('PokemonSprites prefers shiny home then official then front_shiny', () {
    const homeShiny =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/25.png';
    const officialShiny =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/25.png';
    const frontShiny =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/25.png';

    final parsed = PokemonSprites.fromJson({
      'front_default': lowResUrl,
      'front_shiny': frontShiny,
      'other': {
        'official-artwork': {
          'front_default': officialUrl,
          'front_shiny': officialShiny,
        },
        'home': {
          'front_default': homeUrl,
          'front_shiny': homeShiny,
        },
      },
    });

    expect(parsed.shinyDisplayUrl, homeShiny);
    expect(
      PokemonSprites.fromJson({
        'front_shiny': frontShiny,
        'other': {
          'official-artwork': {'front_shiny': officialShiny},
        },
      }).shinyDisplayUrl,
      officialShiny,
    );
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
