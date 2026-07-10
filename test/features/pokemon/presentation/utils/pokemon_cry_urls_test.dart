import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/pokemon/data/mappers/pokemon_mapper.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_cry_urls.dart';

void main() {
  group('PokemonCries', () {
    test('fromJson maps latest and legacy URLs', () {
      const cries = PokemonCries(
        latest: 'https://example.com/latest.ogg',
        legacy: 'https://example.com/legacy.ogg',
      );

      final parsed = PokemonCries.fromJson({
        'latest': cries.latest,
        'legacy': cries.legacy,
      });

      expect(parsed.latest, cries.latest);
      expect(parsed.legacy, cries.legacy);
    });
  });

  group('PokemonMapper.toDetail', () {
    test('maps cry URLs from pokemon response', () {
      const response = PokemonResponse(
        id: 25,
        name: 'pikachu',
        height: 4,
        weight: 60,
        types: [],
        stats: [],
        abilities: [],
        spriteUrl: 'https://example.com/pikachu.png',
        listSpriteUrl: 'https://example.com/pikachu-list.png',
        cries: PokemonCries(
          latest: 'https://example.com/latest.ogg',
          legacy: 'https://example.com/legacy.ogg',
        ),
      );

      final detail = PokemonMapper.toDetail(response, pokeApiCode: 'en');

      expect(detail.cryUrl, response.cries.latest);
      expect(detail.legacyCryUrl, response.cries.legacy);
    });
  });

  group('pokemonCryPlaybackUrls', () {
    test('falls back to pokemon id URLs when cry fields are missing', () {
      expect(
        pokemonCryPlaybackUrls(pokemonId: 25),
        [
          'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/25.ogg',
          'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/legacy/25.ogg',
        ],
      );
    });

    test('returns latest then legacy and skips empty values', () {
      expect(
        pokemonCryPlaybackUrls(
          cryUrl: 'https://example.com/latest.ogg',
          legacyCryUrl: 'https://example.com/legacy.ogg',
        ),
        [
          'https://example.com/latest.ogg',
          'https://example.com/legacy.ogg',
        ],
      );

      expect(
        pokemonCryPlaybackUrls(cryUrl: ''),
        isEmpty,
      );
    });
  });
}
