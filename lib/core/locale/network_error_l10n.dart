import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/offline_cache_error_kind.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

String apiLoadTargetMessage(AppLocalizations l10n, ApiLoadTarget target) {
  return switch (target) {
    ApiLoadTarget.pokemonList => l10n.errorLoadPokemonList,
    ApiLoadTarget.pokemon => l10n.errorLoadPokemon,
    ApiLoadTarget.regions => l10n.errorLoadRegions,
    ApiLoadTarget.region => l10n.errorLoadRegion,
    ApiLoadTarget.pokedex => l10n.errorLoadPokedex,
    ApiLoadTarget.generation => l10n.errorLoadGeneration,
    ApiLoadTarget.type => l10n.errorLoadType,
    ApiLoadTarget.ability => l10n.errorLoadAbility,
    ApiLoadTarget.eggGroup => l10n.errorLoadEggGroup,
    ApiLoadTarget.item => l10n.errorLoadItem,
    ApiLoadTarget.evolutionChain => l10n.errorLoadEvolutionChain,
    ApiLoadTarget.species => l10n.errorLoadSpecies,
    ApiLoadTarget.form => l10n.errorLoadForm,
  };
}

String offlineEmptyCacheMessage(
  AppLocalizations l10n,
  OfflineEmptyCacheException error,
) {
  return switch (error.kind) {
    OfflineCacheErrorKind.emptyPokemonList => l10n.offlineEmptyCacheDefault,
    OfflineCacheErrorKind.pokemonNotCached => l10n.offlinePokemonNotCached,
    OfflineCacheErrorKind.regionPokedexNotCached =>
      l10n.offlineRegionPokedexNotCached(error.regionName ?? ''),
  };
}

String friendlyErrorMessage(AppLocalizations l10n, Object error) {
  if (error is OfflineEmptyCacheException) {
    return offlineEmptyCacheMessage(l10n, error);
  }
  if (isNetworkError(error)) {
    return l10n.errorNetworkOffline;
  }
  if (error is ApiException) {
    if (error.statusCode != null) {
      return l10n.errorLoadDataWithStatus(error.statusCode!);
    }
    if (error.loadTarget != null) {
      return apiLoadTargetMessage(l10n, error.loadTarget!);
    }
  }
  if (error is AppException && error.message.isNotEmpty) {
    return error.message;
  }
  return l10n.errorGenericRetry;
}
