import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_sprite_variant.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:riverpod/misc.dart';

final FutureProviderFamily<List<PokemonSpriteVariant>, int>
pokemonDetailSpriteVariantsProvider =
    FutureProvider.family<List<PokemonSpriteVariant>, int>((
      ref,
      pokemonId,
    ) async {
      final settings = ref.watch(profileSettingsProvider);
      final repo = ref.watch(pokemonRepositoryProvider);
      return repo.getDetailSpriteVariants(
        pokemonId,
        showMegaEvolutions: settings.showMegaEvolutions,
        showOtherForms: settings.showOtherForms,
      );
    });
