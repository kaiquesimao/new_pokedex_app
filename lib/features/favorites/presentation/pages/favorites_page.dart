import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart'
    show PokemonDetail;
import 'package:pokedex_app/shared/widgets/empty_state_illustration.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favoriteIds.isEmpty
          ? const _EmptyFavoritesBody()
          : _FavoritesListBody(favoriteIds: favoriteIds.toList()..sort()),
    );
  }
}

class _EmptyFavoritesBody extends StatelessWidget {
  const _EmptyFavoritesBody();

  @override
  Widget build(BuildContext context) {
    return EmptyStateIllustration(
      imageAsset: AppAssets.patternMagikarp,
      imageHeight: 160,
      title: 'Nenhum Pokémon favorito ainda',
      subtitle:
          'Toque no coração nos cards da Pokédex para adicionar favoritos.',
    );
  }
}

class _FavoritesListBody extends ConsumerWidget {
  const _FavoritesListBody({required this.favoriteIds});

  final List<int> favoriteIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<PokemonDetail>>(
      future: Future.wait(
        favoriteIds.map(
          (id) => ref.read(pokemonRepositoryProvider).getPokemonDetail(id),
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const _EmptyFavoritesBody();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final pokemon = items[index];
            return _DismissibleFavoriteCard(pokemon: pokemon);
          },
        );
      },
    );
  }
}

class _DismissibleFavoriteCard extends ConsumerWidget {
  const _DismissibleFavoriteCard({required this.pokemon});

  final PokemonDetail pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('favorite-${pokemon.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset(
          AppAssets.iconTrash,
          width: 28,
          height: 28,
          color: Colors.white,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
      ),
      onDismissed: (_) {
        ref.read(favoritesProvider.notifier).toggle(pokemon.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pokemon.displayName} removido dos favoritos'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: PokemonListRowCard(
        number: pokemon.id,
        name: pokemon.displayName,
        types: pokemon.types,
        spriteUrl: pokemon.spriteUrl,
        isFavorite: true,
        onTap: () => context.push('/pokemon/${pokemon.id}'),
        onFavoriteTap: () =>
            ref.read(favoritesProvider.notifier).toggle(pokemon.id),
      ),
    );
  }
}
