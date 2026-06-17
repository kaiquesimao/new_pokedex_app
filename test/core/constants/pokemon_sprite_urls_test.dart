import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';

void main() {
  test('homeArtwork builds high-resolution sprite URL', () {
    expect(
      PokemonSpriteUrls.homeArtwork(pokemonId: 1),
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png',
    );
  });

  test('officialArtworkFallbackFor maps home URLs to official artwork', () {
    expect(
      PokemonSpriteUrls.officialArtworkFallbackFor(
        PokemonSpriteUrls.homeArtwork(pokemonId: 25),
      ),
      PokemonSpriteUrls.officialArtwork(pokemonId: 25),
    );
    expect(
      PokemonSpriteUrls.officialArtworkFallbackFor(
        PokemonSpriteUrls.officialArtwork(pokemonId: 25),
      ),
      isNull,
    );
  });

  test('isLowResolutionSpriteUrl detects legacy list sprite URLs', () {
    expect(
      PokemonSpriteUrls.isLowResolutionSpriteUrl(
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
      ),
      isTrue,
    );
    expect(
      PokemonSpriteUrls.isLowResolutionSpriteUrl(
        PokemonSpriteUrls.homeArtwork(pokemonId: 1),
      ),
      isFalse,
    );
    expect(PokemonSpriteUrls.isLowResolutionSpriteUrl(null), isFalse);
  });
}
