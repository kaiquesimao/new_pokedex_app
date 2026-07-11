import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_detail_sprite_variants.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_form_visibility.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_sprite_variant_labels.dart';

void main() {
  const charizard = PokemonSummary(
    id: 6,
    slug: 'charizard',
    name: 'Charizard',
    types: [PokemonType.fire, PokemonType.flying],
    spriteUrl: 'https://example.com/6.png',
    isDefault: true,
  );
  const megaX = PokemonSummary(
    id: 10034,
    slug: 'charizard-mega-x',
    name: 'Charizard',
    types: [PokemonType.fire, PokemonType.dragon],
    spriteUrl: 'https://example.com/10034.png',
    isDefault: false,
    isMega: true,
  );
  const megaY = PokemonSummary(
    id: 10035,
    slug: 'charizard-mega-y',
    name: 'Charizard',
    types: [PokemonType.fire, PokemonType.flying],
    spriteUrl: 'https://example.com/10035.png',
    isDefault: false,
    isMega: true,
  );
  const gmax = PokemonSummary(
    id: 10196,
    slug: 'charizard-gmax',
    name: 'Charizard',
    types: [PokemonType.fire, PokemonType.flying],
    spriteUrl: 'https://example.com/10196.png',
    isDefault: false,
  );
  const alola = PokemonSummary(
    id: 10112,
    slug: 'grimer-alola',
    name: 'Grimer',
    types: [PokemonType.poison, PokemonType.dark],
    spriteUrl: 'https://example.com/10112.png',
    isDefault: false,
  );

  group('buildPokemonDetailSpriteVariants', () {
    test('includes normal, shiny, and visible alternate forms', () {
      final variants = buildPokemonDetailSpriteVariants(
        currentPokemonId: 6,
        currentSpriteUrl: charizard.spriteUrl,
        currentShinySpriteUrl: 'https://example.com/6-shiny.png',
        varietySummaries: [charizard, megaX, megaY, gmax],
        visibility: const PokemonFormVisibility(),
      );

      expect(variants, hasLength(5));
      expect(variants[0].labelKey, PokemonSpriteVariantLabelKeys.normal);
      expect(variants[0].isShiny, isFalse);
      expect(variants[0].pokemonId, 6);
      expect(variants[1].labelKey, PokemonSpriteVariantLabelKeys.shiny);
      expect(variants[1].isShiny, isTrue);
      expect(variants[1].imageUrl, 'https://example.com/6-shiny.png');
      expect(variants[2].labelKey, PokemonSpriteVariantLabelKeys.megaX);
      expect(variants[3].labelKey, PokemonSpriteVariantLabelKeys.megaY);
      expect(variants[4].labelKey, PokemonSpriteVariantLabelKeys.gigantamax);
    });

    test('omits shiny when URL is null and hides carousel extras when alone', () {
      final variants = buildPokemonDetailSpriteVariants(
        currentPokemonId: 6,
        currentSpriteUrl: charizard.spriteUrl,
        currentShinySpriteUrl: null,
        varietySummaries: [charizard],
        visibility: const PokemonFormVisibility(),
      );

      expect(variants, hasLength(1));
      expect(variants.single.labelKey, PokemonSpriteVariantLabelKeys.normal);
    });

    test('respects mega and other-forms visibility toggles', () {
      final variants = buildPokemonDetailSpriteVariants(
        currentPokemonId: 6,
        currentSpriteUrl: charizard.spriteUrl,
        currentShinySpriteUrl: 'https://example.com/6-shiny.png',
        varietySummaries: [charizard, megaX, gmax],
        visibility: const PokemonFormVisibility(
          showMegaEvolutions: false,
          showOtherForms: false,
        ),
      );

      expect(variants.map((v) => v.labelKey), [
        PokemonSpriteVariantLabelKeys.normal,
        PokemonSpriteVariantLabelKeys.shiny,
      ]);
    });

    test('skips varieties without sprite URLs', () {
      const noSprite = PokemonSummary(
        id: 10034,
        slug: 'charizard-mega-x',
        name: 'Charizard',
        types: [PokemonType.fire],
        isDefault: false,
        isMega: true,
      );

      final variants = buildPokemonDetailSpriteVariants(
        currentPokemonId: 6,
        currentSpriteUrl: charizard.spriteUrl,
        currentShinySpriteUrl: null,
        varietySummaries: [charizard, noSprite],
        visibility: const PokemonFormVisibility(),
      );

      expect(variants, hasLength(1));
    });

    test('labels current non-default form from its slug', () {
      final variants = buildPokemonDetailSpriteVariants(
        currentPokemonId: 10112,
        currentSpriteUrl: alola.spriteUrl,
        currentShinySpriteUrl: 'https://example.com/10112-shiny.png',
        varietySummaries: [
          const PokemonSummary(
            id: 88,
            slug: 'grimer',
            name: 'Grimer',
            types: [PokemonType.poison],
            spriteUrl: 'https://example.com/88.png',
            isDefault: true,
          ),
          alola,
        ],
        visibility: const PokemonFormVisibility(),
      );

      expect(variants[0].labelKey, PokemonSpriteVariantLabelKeys.alola);
      expect(variants[1].labelKey, PokemonSpriteVariantLabelKeys.shiny);
      expect(variants[2].labelKey, PokemonSpriteVariantLabelKeys.normal);
    });

    test('returns empty when current sprite is missing', () {
      final variants = buildPokemonDetailSpriteVariants(
        currentPokemonId: 6,
        currentSpriteUrl: null,
        currentShinySpriteUrl: 'https://example.com/6-shiny.png',
        varietySummaries: [charizard, megaX],
        visibility: const PokemonFormVisibility(),
      );

      expect(variants, isEmpty);
    });
  });

  group('PokemonSpriteVariantLabels', () {
    test('maps known form suffixes to stable keys', () {
      expect(
        PokemonSpriteVariantLabels.keyForSummary(charizard),
        PokemonSpriteVariantLabelKeys.normal,
      );
      expect(
        PokemonSpriteVariantLabels.keyForSummary(megaX),
        PokemonSpriteVariantLabelKeys.megaX,
      );
      expect(
        PokemonSpriteVariantLabels.keyForSummary(gmax),
        PokemonSpriteVariantLabelKeys.gigantamax,
      );
      expect(
        PokemonSpriteVariantLabels.keyForSummary(alola),
        PokemonSpriteVariantLabelKeys.alola,
      );
      expect(
        PokemonSpriteVariantLabels.keyForApiName('pikachu-belle'),
        'fallback:belle',
      );
    });
  });
}
