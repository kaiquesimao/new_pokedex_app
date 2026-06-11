import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';

void main() {
  test('officialArtwork builds high-resolution sprite URL', () {
    expect(
      PokemonSpriteUrls.officialArtwork(1),
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
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
        PokemonSpriteUrls.officialArtwork(1),
      ),
      isFalse,
    );
    expect(PokemonSpriteUrls.isLowResolutionSpriteUrl(null), isFalse);
  });
}
