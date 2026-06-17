import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart'
    show PokemonDetail;
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/empty_state_illustration.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_card.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final favoriteIds = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: SafePageBody.inTabShell(
        child: !auth.isAuthenticated
            ? _GuestFavoritesBody(onAuth: () => context.go('/welcome'))
            : favoriteIds.isEmpty
            ? const _EmptyFavoritesBody()
            : _FavoritesListBody(favoriteIds: favoriteIds.toList()..sort()),
      ),
    );
  }
}

class _GuestFavoritesBody extends StatelessWidget {
  const _GuestFavoritesBody({required this.onAuth});

  final VoidCallback onAuth;

  @override
  Widget build(BuildContext context) {
    return EmptyStateIllustration(
      imageAsset: TrainerAvatars.assetPathFor('rhydon_costume'),
      title: 'Você precisa entrar em uma conta para fazer isso.',
      subtitle:
          'Para acessar essa funcionalidade, é necessário fazer login ou '
          'criar uma conta. Faça isso agora!',
      action: AppButton(
        label: 'Entre ou Cadastre-se',
        variant: AppButtonVariant.outline,
        onPressed: onAuth,
      ),
    );
  }
}

class _EmptyFavoritesBody extends StatelessWidget {
  const _EmptyFavoritesBody();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateIllustration(
      imageAsset: AppAssets.patternMagikarp,
      imageHeight: 200,
      title: 'Você não favoritou nenhum Pokémon :(',
      subtitle:
          'Clique no ícone de coração dos seus pokémons favoritos e eles '
          'aparecerão aqui.',
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
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        unawaited(ref.read(favoritesProvider.notifier).toggle(pokemon.id));
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
        heroShellTabIndex: 2,
        onTap: () => context.push('/pokemon/${pokemon.id}'),
        onFavoriteTap: () =>
            ref.read(favoritesProvider.notifier).toggle(pokemon.id),
      ),
    );
  }
}
