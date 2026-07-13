import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart'
    show PokemonDetail;
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';
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
      body: SafePageBody(
        bottom: false,
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppBottomNavBar.overlayHeight(context),
      ),
      child: EmptyStateIllustration(
        imageAsset: TrainerAvatars.assetPathFor('pokemaniac'),
        pixelArt: true,
        title: l10n.favoritesGuestTitle,
        subtitle: l10n.favoritesGuestSubtitle,
        action: AuthHubActionFrame(
          child: AppButton(
            label: l10n.favoritesGuestAction,
            variant: AppButtonVariant.outline,
            onPressed: onAuth,
          ),
        ),
      ),
    );
  }
}

class _EmptyFavoritesBody extends StatelessWidget {
  const _EmptyFavoritesBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppBottomNavBar.overlayHeight(context),
      ),
      child: EmptyStateIllustration(
        imageAsset: AppAssets.patternMagikarp,
        title: l10n.favoritesEmptyTitle,
        subtitle: l10n.favoritesEmptySubtitle,
      ),
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
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            AppBottomNavBar.overlayHeight(context),
          ),
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
    final l10n = AppLocalizations.of(context);
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
            content: Text(l10n.favoritesRemovedSnackbar(pokemon.displayName)),
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
