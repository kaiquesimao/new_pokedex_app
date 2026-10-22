import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/core/theme/skeleton_shimmer_colors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/login_required_bottom_sheet.dart';
import 'package:pokedex_app/features/favorites/presentation/favorite_toggle.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/pages/pokemon_detail_page.dart'
    deferred as pokemon_detail;
import 'package:pokedex_app/features/pokemon/presentation/pokemon_detail_preview.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_detail_bundle_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_detail_header.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/offline_banner.dart';
import 'package:pokedex_app/shared/widgets/pokemon_detail_skeleton.dart';
import 'package:pokedex_app/shared/widgets/responsive_content_frame.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:pokedex_app/shared/widgets/wide_viewport_backdrop.dart';
import 'package:shimmer/shimmer.dart';

class PokemonDetailRoute extends ConsumerStatefulWidget {
  const new({required this.pokemonId, this.preview, super.key});

  final int pokemonId;
  final PokemonDetailPreview? preview;

  @override
  ConsumerState<PokemonDetailRoute> createState() => _PokemonDetailRouteState();
}

class _PokemonDetailRouteState extends ConsumerState<PokemonDetailRoute> {
  late final Future<void> _library = pokemon_detail.loadLibrary();
  var _libraryReady = false;
  var _libraryFailed = false;
  var _transitionSettled = false;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    unawaited(
      _library.then(
        (_) {
          if (!mounted) return;
          setState(() => _libraryReady = true);
        },
        onError: (Object _, StackTrace _) {
          if (!mounted) return;
          setState(() => _libraryFailed = true);
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (identical(animation, _routeAnimation)) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      _transitionSettled = true;
      return;
    }
    animation.addStatusListener(_onRouteStatus);
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() => _transitionSettled = true);
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (previous, next) {
      if (next.value != true) return;

      final current = ref.read(pokemonDetailBundleProvider(widget.pokemonId));
      final shouldReload = current.hasError
          ? isConnectivityFailure(current.error!)
          : current.hasValue && current.requireValue.isOfflineMode;
      if (!shouldReload) return;

      unawaited(() async {
        await ref.read(connectivityServiceProvider).refresh();
        ref.invalidate(pokemonDetailBundleProvider(widget.pokemonId));
      }());
    });

    final bundle = ref.watch(pokemonDetailBundleProvider(widget.pokemonId));
    final preview = widget.preview;
    final showLoaded = showLoadedPokemonDetail(
      hasBundle: bundle.hasValue,
      libraryReady: _libraryReady,
      hasPreview: preview != null,
      transitionSettled: _transitionSettled,
    );

    if (showLoaded && !_libraryFailed) {
      return pokemon_detail.PokemonDetailPage(pokemonId: widget.pokemonId);
    }

    if (preview != null) {
      return _PokemonDetailPreviewPage(
        preview: preview,
        isFavorite: ref.watch(favoritesProvider).contains(widget.pokemonId),
        onFavoriteTap: () => _toggleFavorite(context),
        error: bundle.hasError ? bundle.error : null,
        onRetry: () =>
            ref.invalidate(pokemonDetailBundleProvider(widget.pokemonId)),
      );
    }

    if (_libraryFailed) {
      return Scaffold(
        appBar: AppBar(),
        body: const SafePageBody.belowAppBar(
          child: Center(child: Icon(Icons.error_outline)),
        ),
      );
    }

    if (bundle.hasError) {
      return Scaffold(
        appBar: AppBar(),
        body: SafePageBody.belowAppBar(
          child: OfflineEmptyState(
            message: friendlyErrorMessage(
              AppLocalizations.of(context),
              bundle.error!,
            ),
            isConnectivityFailure: isConnectivityFailure(bundle.error!),
            onRetry: () =>
                ref.invalidate(pokemonDetailBundleProvider(widget.pokemonId)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: wideViewportAwareScaffoldColor(context),
      body: const SafePageBody(
        child: ResponsiveContentFrame(
          expandHeight: true,
          child: PokemonDetailSkeleton(),
        ),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    if (!ref.read(authProvider).isAuthenticated) {
      unawaited(showLoginRequiredBottomSheet(context));
      return;
    }
    toggleAuthenticatedFavorite(
      ref,
      pokemonId: widget.pokemonId,
      context: context,
    );
  }
}

class _PokemonDetailPreviewPage extends StatelessWidget {
  const new({
    required this.preview,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onRetry,
    this.error,
  });

  final PokemonDetailPreview preview;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onRetry;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final primaryType = preview.types.isNotEmpty ? preview.types.first : null;
    final headerColor = primaryType != null
        ? PokemonTypeColors.forType(
            primaryType,
            isDark: Theme.of(context).brightness == Brightness.dark,
          )
        : Theme.of(context).colorScheme.primary;
    final base = SkeletonShimmerColors.base(context);
    final highlight = SkeletonShimmerColors.highlight(context);

    return Scaffold(
      backgroundColor: wideViewportAwareScaffoldColor(context),
      body: SafePageBody(
        child: ResponsiveContentFrame(
          expandHeight: true,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PokemonDetailHeader(
                  primaryType: primaryType,
                  headerColor: headerColor,
                  isFavorite: isFavorite,
                  onBack: () => context.pop(),
                  onFavoriteTap: onFavoriteTap,
                  sprite: PokemonDetailPreviewSprite(
                    pokemonId: preview.id,
                    spriteUrl: preview.spriteUrl,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: PokemonDetailIdentityCard(
                  displayName: preview.displayName,
                  pokemonId: preview.id,
                  types: preview.types,
                ),
              ),
              if (error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: OfflineEmptyState(
                    message: friendlyErrorMessage(
                      AppLocalizations.of(context),
                      error!,
                    ),
                    isConnectivityFailure: isConnectivityFailure(error!),
                    onRetry: onRetry,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Shimmer.fromColors(
                    baseColor: base,
                    highlightColor: highlight,
                    child: const PokemonDetailSectionBlocks(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
