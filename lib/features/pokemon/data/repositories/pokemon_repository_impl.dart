import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/mappers/evolution_mapper.dart';
import 'package:pokedex_app/features/pokemon/data/mappers/pokemon_mapper.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_ref.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_list_filter_utils.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  PokemonRepositoryImpl({required this._remote, required this._local});

  final PokemonRemoteDataSource _remote;
  final PokemonLocalDataSource _local;

  List<NamedApiResource>? _allPokemonRefsCache;
  Future<void>? _warmNameIndexFuture;

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
    final listResponse = await _remote.fetchPokemonList(
      offset: offset,
      limit: limit,
    );

    final ids = listResponse.results.map((r) => r.id).whereType<int>().toList();

    return PokemonListSlice(
      ids: ids,
      totalCount: listResponse.count,
      hasMore: listResponse.next != null,
      nextOffset: offset + limit,
    );
  }

  @override
  Future<EvolutionChain> getEvolutionChain(int pokemonId) async {
    final species = await _remote.fetchPokemonSpecies(pokemonId);
    final chainUrl = species.evolutionChainUrl;
    if (chainUrl == null) {
      final summary = await _loadSummariesForIds([pokemonId]);
      final current = summary.first;
      return EvolutionChain(
        root: EvolutionChainNode(
          speciesId: current.id,
          speciesName: current.name,
          spriteUrl: current.spriteUrl,
        ),
        currentPokemonId: pokemonId,
      );
    }

    final chainId = _extractIdFromUrl(chainUrl);
    if (chainId == null) {
      throw StateError('Invalid evolution chain URL');
    }

    final chainResponse = await _remote.fetchEvolutionChain(chainId);
    final root = EvolutionMapper.toNode(chainResponse.chain);
    final enrichedRoot = await _enrichEvolutionSprites(root);

    return EvolutionChain(root: enrichedRoot, currentPokemonId: pokemonId);
  }

  @override
  Future<PokemonDetail> getPokemonDetail(int id) async {
    final cachedResponse = await _local.getPokemonResponse(id);

    late final PokemonResponse response;
    late final PokemonSpeciesResponse species;

    if (cachedResponse == null) {
      final results = await Future.wait([
        _remote.fetchPokemon(id),
        _remote.fetchPokemonSpecies(id),
      ]);
      response = results[0] as PokemonResponse;
      species = results[1] as PokemonSpeciesResponse;
    } else {
      response = cachedResponse;
      species = await _remote.fetchPokemonSpecies(id);
    }

    final detail = PokemonMapper.toDetail(response, species: species);

    await _local.saveSummary(PokemonMapper.toSummary(response));
    await _local.savePokemonResponse(response);

    return detail;
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

    final listResponse = await _remote.fetchPokemonList(offset: 0, limit: 2000);
    _allPokemonRefsCache = listResponse.results;
    return _mapRefs(_allPokemonRefsCache!);
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

    final listResponse = await _remote.fetchPokemonList(offset: 0, limit: 2000);
    final refs = _mapRefs(listResponse.results);
    await _local.replaceNameIndex(refs);
    _allPokemonRefsCache = listResponse.results;
  }

  @override
  Future<bool> isNameIndexReady() => _local.isNameIndexReady();

  @override
  Future<List<PokemonRef>> searchPokemonRefsByName(String query) async {
    if (!await isNameIndexReady()) {
      await warmPokemonNameIndex();
    }
    return _local.searchRefsByName(query);
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
    final generation = await _remote.fetchGeneration(generationId);
    return generation.pokemonSpecies
        .map((species) => species.id)
        .whereType<int>()
        .toList();
  }

  @override
  Future<List<int>> getPokemonIdsForTypes(List<PokemonType> types) async {
    if (types.isEmpty) return [];

    final ids = <int>{};
    for (final type in types) {
      final typeResponse = await _remote.fetchType(type.apiName);
      ids.addAll(
        typeResponse.pokemon.map((pokemon) => pokemon.id).whereType<int>(),
      );
    }
    return ids.toList();
  }

  @override
  Future<Set<PokemonType>> getTypesWeakTo(PokemonType attackType) async {
    final typeResponse = await _remote.fetchType(attackType.apiName);
    return typeResponse.damageRelations.doubleDamageTo
        .map(PokemonType.fromApiName)
        .whereType<PokemonType>()
        .toSet();
  }

  @override
  Future<PokemonSummary> getSummaryById(int id) async {
    final summaries = await _loadSummariesForIds([id]);
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
    EvolutionChainNode node,
  ) async {
    final ids = _collectSpeciesIds(node);
    final summaries = await _loadSummariesForIds(ids);
    final spriteById = {for (final s in summaries) s.id: s.spriteUrl};
    final nameById = {for (final s in summaries) s.id: s.name};

    return _applySprites(node, spriteById, nameById);
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
    Map<int, String?> spriteById,
    Map<int, String> nameById,
  ) {
    final id = node.speciesId;
    return EvolutionChainNode(
      speciesId: id,
      speciesName: id != null
          ? (nameById[id] ?? node.speciesName)
          : node.speciesName,
      spriteUrl: id != null ? spriteById[id] : null,
      trigger: node.trigger,
      evolvesTo: node.evolvesTo
          .map((child) => _applySprites(child, spriteById, nameById))
          .toList(),
    );
  }

  Future<List<PokemonSummary>> _loadSummariesForIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final cached = await _local.getSummaries(ids);
    final cachedById = {for (final item in cached) item.id: item};

    final results = List<PokemonSummary?>.filled(ids.length, null);
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= ids.length) return;

        final id = ids[index];
        final cachedSummary = cachedById[id];
        if (cachedSummary != null) {
          results[index] = cachedSummary;
          continue;
        }

        final response = await _remote.fetchPokemon(id);
        final summary = PokemonMapper.toSummary(response);
        await _local.saveSummary(summary);
        await _local.savePokemonResponse(response);
        results[index] = summary;
      }
    }

    const concurrency = 8;
    await Future.wait(List.generate(concurrency, (_) => worker()));
    return results.whereType<PokemonSummary>().toList();
  }
}
