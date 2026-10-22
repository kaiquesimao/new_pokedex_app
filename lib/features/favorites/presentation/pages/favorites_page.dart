import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/support/support_prompt_controller.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart'
    show PokemonDetail;
import 'package:pokedex_app/features/pokemon/presentation/navigation/open_pokemon_detail.dart';
import 'package:pokedex_app/features/pokemon/presentation/pokemon_detail_preview.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/empty_state_illustration.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_card.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_skeleton.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class const FavoritesPage({super.key}) extends ConsumerWidget {
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

class const _GuestFavoritesBody({required final VoidCallback onAuth})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppBottomNavBar.overlayHeight(context)),
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

class const _EmptyFavoritesBody() extends ConsumerStatefulWidget {
  @override
  ConsumerState<_EmptyFavoritesBody> createState() =>
      _EmptyFavoritesBodyState();
}

class _EmptyFavoritesBodyState extends ConsumerState<_EmptyFavoritesBody> {
  var _autoPromptScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _autoPromptScheduled) return;
      _autoPromptScheduled = true;
      // Soft moment: auto-popup only when the shared daily cooldown allows.
      scheduleSupportPrompt(
        () => ref
            .read(supportPromptControllerProvider)
            .maybeOnEmptyFavorites(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppBottomNavBar.overlayHeight(context)),
      child: EmptyStateIllustration(
        imageAsset: AppAssets.patternMagikarp,
        title: l10n.favoritesEmptyTitle,
        subtitle: l10n.favoritesEmptySubtitle,
        action: AppButton(
          label: l10n.favoritesEmptySupportCta,
          variant: AppButtonVariant.outline,
          onPressed: () {
            scheduleSupportPrompt(
              () => ref
                  .read(supportPromptControllerProvider)
                  .showFromUserAction(context),
            );
          },
        ),
      ),
    );
  }
}

class const _FavoritesListBody({required final List<int> favoriteIds})
    extends ConsumerWidget {
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
          return const PokemonListSkeleton();
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

class const _DismissibleFavoriteCard({required final PokemonDetail pokemon})
    extends ConsumerWidget {
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
        heroShellTabIndex: 3,
        onTap: () => openPokemonDetail(
          context,
          PokemonDetailPreview(
            id: pokemon.id,
            displayName: pokemon.displayName,
            spriteUrl: pokemon.spriteUrl,
            types: pokemon.types,
          ),
        ),
        onFavoriteTap: () =>
            ref.read(favoritesProvider.notifier).toggle(pokemon.id),
      ),
    );
  }
}
