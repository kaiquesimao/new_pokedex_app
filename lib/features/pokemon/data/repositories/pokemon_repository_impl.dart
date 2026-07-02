import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
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
  PokemonRepositoryImpl({required this._remote, required this._local});

  final PokemonRemoteDataSource _remote;
  final PokemonLocalDataSource _local;

  List<NamedApiResource>? _allPokemonRefsCache;
  Future<void>? _warmNameIndexFuture;
  bool _usedOfflineFallback = false;
  final Map<int, bool> _formMegaCache = {};

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
      final species = await _remote.fetchPokemonSpecies(speciesId);
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
      final enrichedRoot = await _enrichEvolutionSprites(
        root,
        viewingPokemonId: pokemonId,
        viewingSpeciesId: speciesId,
      );

      return EvolutionChain(
        root: enrichedRoot,
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
        'Este Pokémon não está salvo no dispositivo.',
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
        species = await _remote.fetchPokemonSpecies(speciesId);
      } catch (error) {
        if (error is NotFoundException) {
          species = null;
        } else if (!isNetworkError(error)) {
          rethrow;
        } else {
          _markOfflineFallback();
        }
      }

      final detail = PokemonMapper.toDetail(cachedResponse, species: species);

      if (species != null) {
        await _local.saveSummary(PokemonMapper.toSummary(cachedResponse));
        await _local.savePokemonResponse(cachedResponse);
      }

      return detail;
    }

    try {
      final response = await _enrichWithFormMetadata(
        await _remote.fetchPokemon(id),
      );
      final speciesId = await _resolveSpeciesId(id, pokemon: response);
      final species = await _remote.fetchPokemonSpecies(speciesId);
      final detail = PokemonMapper.toDetail(response, species: species);

      await _local.saveSummary(PokemonMapper.toSummary(response));
      await _local.savePokemonResponse(response);

      return detail;
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();
      throw const OfflineEmptyCacheException(
        'Este Pokémon não está salvo no dispositivo.',
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

  Future<List<PokemonRef>> _fetchAllPokemonRefsForIndex() async {
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

    return refs;
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
        'Este Pokémon não está salvo no dispositivo.',
      );
    }
    return summaries.first;
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
        viewingSummary = PokemonMapper.toSummary(cachedDetail);
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

    for (final speciesId in speciesIds.toSet()) {
      final species = await _remote.fetchPokemonSpecies(speciesId);
      final formPokemonId = _pickFormVarietyPokemonId(species, formKey);
      if (formPokemonId != null) {
        mapping[speciesId] = formPokemonId;
      }
    }

    return mapping;
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
      speciesName: summary?.name ?? node.speciesName,
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
          final summary = PokemonMapper.toSummary(enriched);
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
