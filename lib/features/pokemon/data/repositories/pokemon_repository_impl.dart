import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/locale/game_text_resolver.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/offline_cache_error_kind.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/mappers/evolution_mapper.dart';
import 'package:pokedex_app/features/pokemon/data/mappers/pokemon_mapper.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_ref.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_form_visibility.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_list_filter_utils.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  PokemonRepositoryImpl({
    required this._remote,
    required this._local,
    required this._gameTextResolver,
    Ref? ref,
  }) : _getAppLocale = ref != null
           ? (() => ref.read(appLocaleProvider))
           : (() => AppLocale.en) {
    // Only hook provider listener when a Ref is supplied (production usage).
    if (ref != null) {
      // Clear localized caches when app locale changes so localized names/flavor texts refresh.
      ref.listen<AppLocale>(appLocaleProvider, (previous, next) {
        if (previous != next) {
          _speciesCache.clear();
          _gameTextResolver.clearCache();
          // Clear name index so it will be rebuilt with localized names.
          unawaited(Future.microtask(() => _local.replaceNameIndex(const [])));
          _warmNameIndexFuture = null;
          unawaited(Future.microtask(warmPokemonNameIndex));
        }
      });
    }
  }

  final PokemonRemoteDataSource _remote;
  final PokemonLocalDataSource _local;
  final GameTextResolver _gameTextResolver;
  final AppLocale Function() _getAppLocale;

  List<NamedApiResource>? _allPokemonRefsCache;
  Future<void>? _warmNameIndexFuture;
  bool _usedOfflineFallback = false;
  final Map<int, bool> _formMegaCache = {};
  final Map<int, PokemonSpeciesResponse> _speciesCache = {};

  @override
  bool takeOfflineFallbackUsed() {
    final value = _usedOfflineFallback;
    _usedOfflineFallback = false;
    return value;
  }

  void _markOfflineFallback() {
    _usedOfflineFallback = true;
  }

  @override
  Future<PokemonPage> getPokemonPage({
    required int offset,
    int limit = 20,
  }) async {
    final slice = await getPokemonListSlice(offset: offset, limit: limit);
    final summaries = await _loadSummariesForIds(slice.ids);

    return PokemonPage(
      items: summaries,
      totalCount: slice.totalCount,
      hasMore: slice.hasMore,
      nextOffset: slice.nextOffset,
    );
  }

  @override
  Future<PokemonListSlice> getPokemonListSlice({
    required int offset,
    int limit = 20,
  }) async {
    try {
      final listResponse = await _remote.fetchPokemonList(
        offset: offset,
        limit: limit,
      );

      final ids = listResponse.results
          .map((r) => r.id)
          .whereType<int>()
          .toList();

      return PokemonListSlice(
        ids: ids,
        totalCount: listResponse.count,
        hasMore: listResponse.next != null,
        nextOffset: offset + limit,
      );
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();
      return _listSliceFromCache(offset: offset, limit: limit);
    }
  }

  Future<PokemonListSlice> _listSliceFromCache({
    required int offset,
    required int limit,
  }) async {
    final total = await _local.countCachedSummaries();
    if (total == 0) {
      throw const OfflineEmptyCacheException();
    }

    final summaries = await _local.getCachedSummariesPage(
      offset: offset,
      limit: limit,
    );

    return PokemonListSlice(
      ids: summaries.map((summary) => summary.id).toList(),
      totalCount: total,
      hasMore: offset + limit < total,
      nextOffset: offset + limit,
      fromCache: true,
    );
  }

  @override
  Future<EvolutionChain> getEvolutionChain(int pokemonId) async {
    try {
      final speciesId = await _resolveSpeciesId(pokemonId);
      final species = await _getCachedSpecies(speciesId);
      final chainUrl = species.evolutionChainUrl;
      if (chainUrl == null) {
        return _singleNodeEvolutionChain(pokemonId);
      }

      final chainId = _extractIdFromUrl(chainUrl);
      if (chainId == null) {
        throw StateError('Invalid evolution chain URL');
      }

      final chainResponse = await _remote.fetchEvolutionChain(chainId);
      final root = EvolutionMapper.toNode(chainResponse.chain);
      final pokeApiCode = _getAppLocale().pokeApiCode;
      final enrichedRoot = await _enrichEvolutionChain(root, pokeApiCode);
      final enrichedWithSprites = await _enrichEvolutionSprites(
        enrichedRoot,
        viewingPokemonId: pokemonId,
        viewingSpeciesId: speciesId,
      );

      return EvolutionChain(
        root: enrichedWithSprites,
        currentPokemonId: pokemonId,
        currentSpeciesId: speciesId,
      );
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();
      return _singleNodeEvolutionChain(pokemonId);
    }
  }

  Future<EvolutionChain> _singleNodeEvolutionChain(int pokemonId) async {
    final summaries = await _loadSummariesForIds([pokemonId]);
    if (summaries.isEmpty) {
      throw const OfflineEmptyCacheException(
        kind: OfflineCacheErrorKind.pokemonNotCached,
      );
    }

    final current = summaries.first;
    final speciesId = await _resolveSpeciesIdOfflineSafe(pokemonId);
    return EvolutionChain(
      root: EvolutionChainNode(
        speciesId: speciesId,
        pokemonId: pokemonId,
        speciesName: current.name,
        spriteUrl: current.spriteUrl,
        types: current.types,
      ),
      currentPokemonId: pokemonId,
      currentSpeciesId: speciesId,
    );
  }

  @override
  Future<PokemonDetail> getPokemonDetail(int id) async {
    var cachedResponse = await _local.getPokemonResponse(
      id,
      allowStale: true,
    );

    if (cachedResponse != null) {
      cachedResponse = await _enrichWithFormMetadata(cachedResponse);
      PokemonSpeciesResponse? species;
      try {
        final speciesId = await _resolveSpeciesId(
          id,
          pokemon: cachedResponse,
        );
        species = await _getCachedSpecies(speciesId);
      } catch (error) {
        if (error is NotFoundException) {
          species = null;
        } else if (!isNetworkError(error)) {
          rethrow;
        } else {
          _markOfflineFallback();
        }
      }

      final pokeApiCode = _getAppLocale().pokeApiCode;
      var detail = PokemonMapper.toDetail(
        cachedResponse,
        species: species,
        pokeApiCode: pokeApiCode,
      );
      detail = await _enrichDetailAbilities(detail, pokeApiCode);
      detail = await _enrichDetailEggGroups(detail, pokeApiCode);
      if (species != null) {
        detail = await _enrichDetailCategory(detail, species, pokeApiCode);
      }

      if (species != null) {
        await _local.saveSummary(
          PokemonMapper.toSummary(
            cachedResponse,
            species: species,
            pokeApiCode: pokeApiCode,
          ),
        );
        await _local.savePokemonResponse(cachedResponse);
      }

      return detail;
    }

    try {
      final response = await _enrichWithFormMetadata(
        await _remote.fetchPokemon(id),
      );
      final speciesId = await _resolveSpeciesId(id, pokemon: response);
      final species = await _getCachedSpecies(speciesId);
      final pokeApiCode = _getAppLocale().pokeApiCode;
      var detail = PokemonMapper.toDetail(
        response,
        species: species,
        pokeApiCode: pokeApiCode,
      );
      detail = await _enrichDetailAbilities(detail, pokeApiCode);
      detail = await _enrichDetailEggGroups(detail, pokeApiCode);
      detail = await _enrichDetailCategory(detail, species, pokeApiCode);

      await _local.saveSummary(
        PokemonMapper.toSummary(
          response,
          species: species,
          pokeApiCode: pokeApiCode,
        ),
      );
      await _local.savePokemonResponse(response);

      return detail;
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();
      throw const OfflineEmptyCacheException(
        kind: OfflineCacheErrorKind.pokemonNotCached,
      );
    }
  }

  @override
  Future<List<PokemonRef>> getAllPokemonRefs() async {
    if (_allPokemonRefsCache != null) {
      return _mapRefs(_allPokemonRefsCache!);
    }

    final indexed = await getIndexedPokemonRefs();
    if (indexed.isNotEmpty) {
      _allPokemonRefsCache = indexed
          .map(
            (ref) =>
                NamedApiResource(name: ref.name, url: '/pokemon/${ref.id}/'),
          )
          .toList();
      return indexed;
    }

    try {
      final listResponse = await _remote.fetchPokemonList(
        limit: 2000,
      );
      _allPokemonRefsCache = listResponse.results;
      return _mapRefs(_allPokemonRefsCache!);
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      return _refsFromCachedSummaries();
    }
  }

  Future<List<PokemonRef>> _refsFromCachedSummaries() async {
    final ids = await _local.getAllCachedSummaryIds();
    if (ids.isEmpty) return [];

    final summaries = await _local.getSummaries(ids, allowStale: true);
    return summaries
        .map((summary) => PokemonRef(id: summary.id, name: summary.name))
        .toList();
  }

  @override
  Future<void> warmPokemonNameIndex() {
    return _warmNameIndexFuture ??= _warmPokemonNameIndex();
  }

  Future<void> _warmPokemonNameIndex() async {
    if (await isNameIndexReady()) {
      final indexed = await _local.getIndexedRefs();
      if (indexed.isNotEmpty) {
        _allPokemonRefsCache = indexed
            .map(
              (ref) =>
                  NamedApiResource(name: ref.name, url: '/pokemon/${ref.id}/'),
            )
            .toList();
        return;
      }
    }

    try {
      final refs = await _fetchAllPokemonRefsForIndex();
      await _local.replaceNameIndex(refs);
      _allPokemonRefsCache = refs
          .map(
            (ref) =>
                NamedApiResource(name: ref.name, url: '/pokemon/${ref.id}/'),
          )
          .toList();
    } catch (error) {
      if (error is! NetworkException && error is! ApiException) rethrow;
    }
  }

  Future<List<({int id, String name, String localizedName})>>
  _fetchAllPokemonRefsForIndex() async {
    const pageSize = 100;
    final refs = <PokemonRef>[];
    var offset = 0;

    while (true) {
      final page = await _remote.fetchPokemonList(
        offset: offset,
        limit: pageSize,
      );
      refs.addAll(_mapRefs(page.results));
      if (page.next == null) break;
      offset += pageSize;
    }
    // Enrich with localized names by fetching species for each pokemon.
    final entries = List<({int id, String name, String localizedName})?>.filled(
      refs.length,
      null,
    );
    var nextIndex = 0;
    final pokeApiCode = _getAppLocale().pokeApiCode;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= refs.length) return;
        final ref = refs[index];
        try {
          final pokemon = await _remote.fetchPokemon(ref.id);
          final speciesId = pokemon.speciesId ?? ref.id;
          final species = await _remote.fetchPokemonSpecies(speciesId);
          final localized = species.localizedName(pokeApiCode) ?? ref.name;
          entries[index] = (
            id: ref.id,
            name: ref.name,
            localizedName: localized,
          );
        } catch (error) {
          if (!isNetworkError(error)) rethrow;
          _markOfflineFallback();
          entries[index] = (
            id: ref.id,
            name: ref.name,
            localizedName: ref.name,
          );
        }
      }
    }

    const concurrency = 8;
    await Future.wait(List.generate(concurrency, (_) => worker()));
    return entries
        .whereType<({int id, String name, String localizedName})>()
        .toList();
  }

  @override
  Future<bool> isNameIndexReady() => _local.isNameIndexReady();

  @override
  Future<List<PokemonRef>> searchPokemonRefsByName(String query) async {
    if (!await isNameIndexReady()) {
      try {
        await warmPokemonNameIndex();
      } on Object catch (_) {
        // Fall back to cached summaries below.
      }
    }

    if (await isNameIndexReady()) {
      return _local.searchRefsByName(query);
    }

    return _local.searchCachedRefsByName(query);
  }

  @override
  Future<List<PokemonRef>> getIndexedPokemonRefs() async {
    if (!await isNameIndexReady()) {
      return [];
    }
    return _local.getIndexedRefs();
  }

  List<PokemonRef> _mapRefs(List<NamedApiResource> refs) {
    return refs
        .map(
          (ref) =>
              ref.id == null ? null : PokemonRef(id: ref.id!, name: ref.name),
        )
        .whereType<PokemonRef>()
        .toList();
  }

  @override
  Future<List<int>> getPokemonIdsForGeneration(int generationId) async {
    try {
      final generation = await _remote.fetchGeneration(generationId);
      return generation.pokemonSpecies
          .map((species) => species.id)
          .whereType<int>()
          .toList();
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      return _local.getAllCachedSummaryIds();
    }
  }

  @override
  Future<List<int>> getPokemonIdsForTypes(List<PokemonType> types) async {
    if (types.isEmpty) return [];

    try {
      final ids = <int>{};
      for (final type in types) {
        final typeResponse = await _remote.fetchType(type.apiName);
        ids.addAll(
          typeResponse.pokemon.map((pokemon) => pokemon.id).whereType<int>(),
        );
      }
      return ids.toList();
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      return _filterCachedIdsByTypes(types);
    }
  }

  Future<List<int>> _filterCachedIdsByTypes(List<PokemonType> types) async {
    final ids = await _local.getAllCachedSummaryIds();
    if (ids.isEmpty) return [];

    final summaries = await _local.getSummaries(ids, allowStale: true);
    return summaries
        .where((summary) => summary.types.any((type) => types.contains(type)))
        .map((summary) => summary.id)
        .toList();
  }

  @override
  Future<Set<PokemonType>> getTypesWeakTo(PokemonType attackType) async {
    try {
      final typeResponse = await _remote.fetchType(attackType.apiName);
      return typeResponse.damageRelations.doubleDamageTo
          .map(PokemonType.fromApiName)
          .whereType<PokemonType>()
          .toSet();
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      return const {};
    }
  }

  @override
  Future<PokemonSummary> getSummaryById(int id) async {
    final summaries = await _loadSummariesForIds([id]);
    if (summaries.isEmpty) {
      throw const OfflineEmptyCacheException(
        kind: OfflineCacheErrorKind.pokemonNotCached,
      );
    }
    return summaries.first;
  }

  @override
  Future<int> resolvePokemonIdForRegionalSpecies(
    int speciesId,
    String regionalFormKey,
  ) async {
    final species = await _getCachedSpecies(speciesId);
    return _pickFormVarietyPokemonId(species, regionalFormKey) ?? speciesId;
  }

  @override
  Future<List<PokemonSummary>> getSummariesByIds(
    List<int> ids, {
    PokemonListFilters? filters,
    Set<PokemonType>? weakToTypes,
  }) async {
    final summaries = await _loadSummariesForIds(ids);
    if (filters == null) return summaries;

    return PokemonListFilterUtils.apply(
      items: summaries,
      filters: filters,
      weakToTypes: weakToTypes,
    );
  }

  int? _extractIdFromUrl(String url) {
    final match = RegExp(r'/(\d+)/?$').firstMatch(url);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  Future<EvolutionChainNode> _enrichEvolutionSprites(
    EvolutionChainNode node, {
    int? viewingPokemonId,
    int? viewingSpeciesId,
  }) async {
    final speciesIds = _collectSpeciesIds(node);

    PokemonSummary? viewingSummary;
    String? viewingName;
    if (viewingPokemonId != null) {
      final cachedDetail = await _local.getPokemonResponse(
        viewingPokemonId,
        allowStale: true,
      );
      if (cachedDetail != null && cachedDetail.name.isNotEmpty) {
        final pokeApiCode = _getAppLocale().pokeApiCode;
        viewingSummary = PokemonMapper.toSummary(
          cachedDetail,
          pokeApiCode: pokeApiCode,
        );
        viewingName = cachedDetail.name;
      } else {
        final loaded = await _loadSummariesForIds([viewingPokemonId]);
        if (loaded.isNotEmpty) {
          viewingSummary = loaded.first;
          viewingName = viewingSummary.name;
        }
      }
    }

    final regionalFormKey = viewingName != null
        ? PokemonFormVisibility.regionalFormKey(viewingName)
        : null;
    final pokemonIdBySpeciesId = regionalFormKey != null
        ? await _resolvePokemonIdsForFormLine(speciesIds, regionalFormKey)
        : {for (final id in speciesIds) id: id};

    final pokemonIdsToLoad = pokemonIdBySpeciesId.values.toSet().toList();
    final summaries = await _loadSummariesForIds(pokemonIdsToLoad);
    final summaryByPokemonId = {for (final s in summaries) s.id: s};

    return _applySprites(
      node,
      summaryByPokemonId,
      pokemonIdBySpeciesId,
      viewingSpeciesId: viewingSpeciesId,
      viewingSummary:
          viewingName != null && PokemonFormVisibility.isMegaForm(viewingName)
          ? viewingSummary
          : null,
    );
  }

  Future<Map<int, int>> _resolvePokemonIdsForFormLine(
    List<int> speciesIds,
    String formKey,
  ) async {
    final mapping = <int, int>{for (final id in speciesIds) id: id};
    final uniqueIds = speciesIds.toSet();

    await Future.wait(uniqueIds.map(_getCachedSpecies));

    for (final speciesId in uniqueIds) {
      final species = _speciesCache[speciesId]!;
      final formPokemonId = _pickFormVarietyPokemonId(species, formKey);
      if (formPokemonId != null) {
        mapping[speciesId] = formPokemonId;
      }
    }

    return mapping;
  }

  Future<PokemonSpeciesResponse> _getCachedSpecies(int speciesId) async {
    final cached = _speciesCache[speciesId];
    if (cached != null) return cached;

    final species = await _remote.fetchPokemonSpecies(speciesId);
    _speciesCache[speciesId] = species;
    return species;
  }

  /// Return a localized display name for an ability `slug` (e.g. "overgrow").
  Future<String?> getAbilityDisplayName(String slug, String pokeApiCode) async {
    try {
      final resolved = await _gameTextResolver.resolveResource(
        resource: ApiLoadTarget.ability,
        slug: slug,
        kind: GameTextKind.name,
        targetLang: pokeApiCode,
      );
      return resolved.text;
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();
      return null;
    }
  }

  Future<PokemonDetail> _enrichDetailAbilities(
    PokemonDetail detail,
    String pokeApiCode,
  ) async {
    final resolved = await Future.wait(
      detail.abilities.map((a) async {
        final display = await getAbilityDisplayName(a.name, pokeApiCode);
        return PokemonAbility(
          name: display ?? _capitalize(a.name),
          isHidden: a.isHidden,
        );
      }),
    );

    return PokemonDetail(
      id: detail.id,
      name: detail.name,
      height: detail.height,
      weight: detail.weight,
      types: detail.types,
      stats: detail.stats,
      abilities: resolved,
      spriteUrl: detail.spriteUrl,
      flavorText: detail.flavorText,
      genderRate: detail.genderRate,
      captureRate: detail.captureRate,
      baseHappiness: detail.baseHappiness,
      hatchCounter: detail.hatchCounter,
      eggGroups: detail.eggGroups,
      category: detail.category,
      flavorTextEntries: detail.flavorTextEntries,
    );
  }

  Future<String?> getEggGroupDisplayName(
    String slug,
    String pokeApiCode,
  ) async {
    try {
      final resolved = await _gameTextResolver.resolveResource(
        resource: ApiLoadTarget.eggGroup,
        slug: slug,
        kind: GameTextKind.name,
        targetLang: pokeApiCode,
      );
      return resolved.text;
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();
      return null;
    }
  }

  Future<PokemonDetail> _enrichDetailEggGroups(
    PokemonDetail detail,
    String pokeApiCode,
  ) async {
    if (detail.eggGroups.isEmpty) return detail;

    final localized = await Future.wait(
      detail.eggGroups.map((slug) async {
        final display = await getEggGroupDisplayName(slug, pokeApiCode);
        return display ?? _capitalize(slug);
      }),
    );

    return PokemonDetail(
      id: detail.id,
      name: detail.name,
      height: detail.height,
      weight: detail.weight,
      types: detail.types,
      stats: detail.stats,
      abilities: detail.abilities,
      spriteUrl: detail.spriteUrl,
      flavorText: detail.flavorText,
      genderRate: detail.genderRate,
      captureRate: detail.captureRate,
      baseHappiness: detail.baseHappiness,
      hatchCounter: detail.hatchCounter,
      eggGroups: localized,
      category: detail.category,
      flavorTextEntries: detail.flavorTextEntries,
    );
  }

  Future<PokemonDetail> _enrichDetailCategory(
    PokemonDetail detail,
    PokemonSpeciesResponse species,
    String pokeApiCode,
  ) async {
    if (species.genera.isEmpty) return detail;

    final resolved = await _gameTextResolver.resolveFromEntries(
      entries: species.genera,
      kind: GameTextKind.name,
      targetLang: pokeApiCode,
      textKey: 'genus',
    );

    return PokemonDetail(
      id: detail.id,
      name: detail.name,
      height: detail.height,
      weight: detail.weight,
      types: detail.types,
      stats: detail.stats,
      abilities: detail.abilities,
      spriteUrl: detail.spriteUrl,
      flavorText: detail.flavorText,
      genderRate: detail.genderRate,
      captureRate: detail.captureRate,
      baseHappiness: detail.baseHappiness,
      hatchCounter: detail.hatchCounter,
      eggGroups: detail.eggGroups,
      category: resolved.text,
      flavorTextEntries: detail.flavorTextEntries,
    );
  }

  Future<String?> getItemDisplayName(String slug, String pokeApiCode) async {
    try {
      final resolved = await _gameTextResolver.resolveResource(
        resource: ApiLoadTarget.item,
        slug: slug,
        kind: GameTextKind.name,
        targetLang: pokeApiCode,
      );
      return resolved.text;
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();
      return null;
    }
  }

  Future<EvolutionChainNode> _enrichEvolutionChain(
    EvolutionChainNode node,
    String pokeApiCode,
  ) async {
    EvolutionTriggerInfo? enrichedTrigger;
    final trigger = node.trigger;
    if (trigger != null) {
      String? itemDisplayName;
      String? heldItemDisplayName;
      if (trigger.itemSlug != null && trigger.itemSlug!.isNotEmpty) {
        itemDisplayName = await getItemDisplayName(
          trigger.itemSlug!,
          pokeApiCode,
        );
      }
      if (trigger.heldItemSlug != null && trigger.heldItemSlug!.isNotEmpty) {
        heldItemDisplayName = await getItemDisplayName(
          trigger.heldItemSlug!,
          pokeApiCode,
        );
      }
      enrichedTrigger = EvolutionTriggerInfo(
        minLevel: trigger.minLevel,
        trigger: trigger.trigger,
        itemSlug: trigger.itemSlug,
        itemDisplayName:
            itemDisplayName ??
            (trigger.itemSlug != null ? _capitalize(trigger.itemSlug!) : null),
        timeOfDay: trigger.timeOfDay,
        heldItemSlug: trigger.heldItemSlug,
        heldItemDisplayName:
            heldItemDisplayName ??
            (trigger.heldItemSlug != null
                ? _capitalize(trigger.heldItemSlug!)
                : null),
      );
    }

    final enrichedChildren = await Future.wait(
      node.evolvesTo.map(
        (child) => _enrichEvolutionChain(child, pokeApiCode),
      ),
    );

    return EvolutionChainNode(
      speciesId: node.speciesId,
      speciesName: node.speciesName,
      localizedDisplayName: node.localizedDisplayName,
      pokemonId: node.pokemonId,
      spriteUrl: node.spriteUrl,
      types: node.types,
      trigger: enrichedTrigger ?? trigger,
      evolvesTo: enrichedChildren,
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  int? _pickFormVarietyPokemonId(
    PokemonSpeciesResponse species,
    String formKey,
  ) {
    for (final variety in species.varieties) {
      if (variety.pokemonName.endsWith('-$formKey')) {
        return variety.pokemonId;
      }
    }
    return null;
  }

  List<int> _collectSpeciesIds(EvolutionChainNode node) {
    final ids = <int>[];
    if (node.speciesId != null) ids.add(node.speciesId!);
    for (final child in node.evolvesTo) {
      ids.addAll(_collectSpeciesIds(child));
    }
    return ids;
  }

  EvolutionChainNode _applySprites(
    EvolutionChainNode node,
    Map<int, PokemonSummary> summaryByPokemonId,
    Map<int, int> pokemonIdBySpeciesId, {
    int? viewingSpeciesId,
    PokemonSummary? viewingSummary,
  }) {
    final speciesId = node.speciesId;
    final pokemonId = speciesId != null
        ? pokemonIdBySpeciesId[speciesId]
        : null;

    final isMegaViewingStage =
        speciesId != null &&
        viewingSpeciesId == speciesId &&
        viewingSummary != null;
    final summary = isMegaViewingStage
        ? viewingSummary
        : (pokemonId != null ? summaryByPokemonId[pokemonId] : null);

    return EvolutionChainNode(
      speciesId: speciesId,
      pokemonId: summary?.id ?? pokemonId,
      speciesName: summary?.slug ?? node.speciesName,
      localizedDisplayName: summary?.name,
      spriteUrl: summary?.spriteUrl,
      types: summary?.types ?? node.types,
      trigger: node.trigger,
      evolvesTo: node.evolvesTo
          .map(
            (child) => _applySprites(
              child,
              summaryByPokemonId,
              pokemonIdBySpeciesId,
              viewingSpeciesId: viewingSpeciesId,
              viewingSummary: viewingSummary,
            ),
          )
          .toList(),
    );
  }

  Future<List<PokemonSummary>> _loadSummariesForIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final cached = await _local.getSummaries(ids);
    final staleCached = await _local.getSummaries(ids, allowStale: true);
    final cachedById = {for (final item in cached) item.id: item};
    final staleById = {for (final item in staleCached) item.id: item};

    final results = List<PokemonSummary?>.filled(ids.length, null);
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= ids.length) return;

        final id = ids[index];
        final cachedSummary = cachedById[id];
        if (cachedSummary != null && cachedSummary.name.isNotEmpty) {
          results[index] = cachedSummary;
          continue;
        }

        try {
          final response = await _remote.fetchPokemon(id);
          final enriched = await _enrichWithFormMetadata(response);
          final pokeApiCode = _getAppLocale().pokeApiCode;
          final summary = PokemonMapper.toSummary(
            enriched,
            pokeApiCode: pokeApiCode,
          );
          await _local.saveSummary(summary);
          await _local.savePokemonResponse(enriched);
          results[index] = summary;
        } catch (error) {
          if (!isNetworkError(error)) rethrow;
          _markOfflineFallback();
          results[index] = staleById[id];
        }
      }
    }

    const concurrency = 8;
    await Future.wait(List.generate(concurrency, (_) => worker()));
    return results.whereType<PokemonSummary>().toList();
  }

  Future<int> _resolveSpeciesId(
    int pokemonId, {
    PokemonResponse? pokemon,
  }) async {
    final cached =
        pokemon ?? await _local.getPokemonResponse(pokemonId, allowStale: true);
    final cachedSpeciesId = cached?.speciesId;
    if (cachedSpeciesId != null &&
        !_isStaleSpeciesId(pokemonId, cachedSpeciesId)) {
      return cachedSpeciesId;
    }

    final response = await _remote.fetchPokemon(pokemonId);
    if (response.speciesId != null) {
      await _local.savePokemonResponse(response);
      return response.speciesId!;
    }

    return pokemonId;
  }

  /// Alternate forms (id > 10000) may have stale cache with species_id == id.
  bool _isStaleSpeciesId(int pokemonId, int speciesId) {
    return speciesId == pokemonId && pokemonId > 10000;
  }

  Future<int> _resolveSpeciesIdOfflineSafe(int pokemonId) async {
    final cached = await _local.getPokemonResponse(pokemonId, allowStale: true);
    final cachedSpeciesId = cached?.speciesId;
    if (cachedSpeciesId != null &&
        !_isStaleSpeciesId(pokemonId, cachedSpeciesId)) {
      return cachedSpeciesId;
    }
    return pokemonId;
  }

  Future<PokemonResponse> _enrichWithFormMetadata(
    PokemonResponse response,
  ) async {
    if (response.isDefault) {
      return response.isMega == false
          ? response
          : response.copyWith(isMega: false);
    }

    if (response.isMega != null) return response;

    final isMega = await _resolveIsMega(response);
    return response.copyWith(isMega: isMega);
  }

  Future<bool> _resolveIsMega(PokemonResponse response) async {
    final formId = response.primaryFormId;
    if (formId == null) {
      return PokemonFormVisibility.isMegaForm(response.name);
    }

    final cached = _formMegaCache[formId];
    if (cached != null) return cached;

    try {
      final form = await _remote.fetchPokemonForm(formId);
      _formMegaCache[formId] = form.isMega;
      return form.isMega;
    } on Object catch (_) {
      return PokemonFormVisibility.isMegaForm(response.name);
    }
  }
}
