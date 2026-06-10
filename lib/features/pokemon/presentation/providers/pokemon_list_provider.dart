import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_list_filter_utils.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_filters_provider.dart';

class PokemonListState {
  const PokemonListState({
    this.items = const [],
    this.isLoadingIds = false,
    this.isLoadingSummaries = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextOffset = 0,
    this.lockedItemCount = 0,
    this.batchTarget = 0,
    this.error,
    this.catalogIds = const [],
    this.catalogCursor = 0,
  });

  final List<PokemonSummary> items;
  final bool isLoadingIds;
  final bool isLoadingSummaries;
  final bool isLoadingMore;
  final bool hasMore;
  final int nextOffset;
  final int lockedItemCount;
  final int batchTarget;
  final String? error;
  final List<int> catalogIds;
  final int catalogCursor;

  bool get isInitialLoading => isLoadingIds && items.isEmpty;

  bool get showFullSkeleton =>
      items.isEmpty && (isLoadingIds || isLoadingSummaries);

  PokemonListState copyWith({
    List<PokemonSummary>? items,
    bool? isLoadingIds,
    bool? isLoadingSummaries,
    bool? isLoadingMore,
    bool? hasMore,
    int? nextOffset,
    int? lockedItemCount,
    int? batchTarget,
    String? error,
    bool clearError = false,
    List<int>? catalogIds,
    int? catalogCursor,
  }) {
    return PokemonListState(
      items: items ?? this.items,
      isLoadingIds: isLoadingIds ?? this.isLoadingIds,
      isLoadingSummaries: isLoadingSummaries ?? this.isLoadingSummaries,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
      lockedItemCount: lockedItemCount ?? this.lockedItemCount,
      batchTarget: batchTarget ?? this.batchTarget,
      error: clearError ? null : (error ?? this.error),
      catalogIds: catalogIds ?? this.catalogIds,
      catalogCursor: catalogCursor ?? this.catalogCursor,
    );
  }
}

class PokemonListNotifier extends StateNotifier<PokemonListState> {
  PokemonListNotifier(this._repository, this._filtersNotifier)
    : super(const PokemonListState());

  final PokemonRepository _repository;
  final PokemonFiltersNotifier _filtersNotifier;

  static const int _pageSize = 20;
  static const int _catalogBatchSize = 20;
  static const int _concurrency = 8;

  int _loadGeneration = 0;
  Set<PokemonType>? _weakToTypesCache;
  PokemonType? _weakToTypesFor;

  Future<void> loadInitial() async {
    if (state.isLoadingIds || state.isLoadingSummaries) return;

    final generation = ++_loadGeneration;
    state = const PokemonListState(isLoadingIds: true);

    try {
      final filters = _filtersNotifier.state;
      if (filters.usesSearchOnlyMode) {
        await _loadSearchInitial(filters, generation);
      } else if (filters.usesCatalogMode) {
        await _loadCatalogInitial(filters, generation);
      } else {
        await _loadPaginatedInitial(generation);
      }
    } catch (error) {
      if (generation != _loadGeneration) return;
      state = PokemonListState(error: error.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.isLoadingSummaries ||
        state.isLoadingIds ||
        !state.hasMore) {
      return;
    }

    final generation = _loadGeneration;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final filters = _filtersNotifier.state;
      if (filters.usesSearchOnlyMode) {
        await _loadSearchMore(generation);
      } else if (filters.usesCatalogMode) {
        await _loadCatalogMore(filters, generation);
      } else {
        await _loadPaginatedMore(generation);
      }
    } catch (error) {
      if (generation != _loadGeneration) return;
      state = state.copyWith(isLoadingMore: false, error: error.toString());
    }
  }

  Future<void> reloadForFilters(PokemonListFilters filters) async {
    _weakToTypesCache = null;
    _weakToTypesFor = null;
    _loadGeneration++;
    state = const PokemonListState();
    await loadInitial();
  }

  Future<void> _loadPaginatedInitial(int generation) async {
    final slice = await _repository.getPokemonListSlice(
      offset: 0,
      limit: _pageSize,
    );

    if (generation != _loadGeneration) return;

    await _loadBatchProgressive(
      ids: slice.ids,
      generation: generation,
      lockedItems: const [],
      hasMore: slice.hasMore,
      nextOffset: slice.nextOffset,
      filters: null,
      weakToTypes: null,
      catalogIds: const [],
      catalogCursor: 0,
    );
  }

  Future<void> _loadPaginatedMore(int generation) async {
    final slice = await _repository.getPokemonListSlice(
      offset: state.nextOffset,
      limit: _pageSize,
    );

    if (generation != _loadGeneration) return;

    await _loadBatchProgressive(
      ids: slice.ids,
      generation: generation,
      lockedItems: state.items,
      hasMore: slice.hasMore,
      nextOffset: slice.nextOffset,
      filters: null,
      weakToTypes: null,
      catalogIds: state.catalogIds,
      catalogCursor: state.catalogCursor,
    );
  }

  Future<void> _loadSearchInitial(
    PokemonListFilters filters,
    int generation,
  ) async {
    final sortedIds = await _resolveSearchOnlyIds(filters);

    if (generation != _loadGeneration) return;

    if (sortedIds.isEmpty) {
      state = const PokemonListState(hasMore: false);
      return;
    }

    final batch = sortedIds.take(_catalogBatchSize).toList();

    await _loadBatchProgressive(
      ids: batch,
      generation: generation,
      lockedItems: const [],
      hasMore: sortedIds.length > batch.length,
      nextOffset: 0,
      filters: null,
      weakToTypes: null,
      catalogIds: sortedIds,
      catalogCursor: batch.length,
    );
  }

  Future<void> _loadSearchMore(int generation) async {
    final remaining = state.catalogIds.skip(state.catalogCursor).toList();
    final batch = remaining.take(_catalogBatchSize).toList();

    if (batch.isEmpty) {
      state = state.copyWith(isLoadingMore: false, hasMore: false);
      return;
    }

    await _loadBatchProgressive(
      ids: batch,
      generation: generation,
      lockedItems: state.items,
      hasMore: state.catalogCursor + batch.length < state.catalogIds.length,
      nextOffset: state.nextOffset,
      filters: null,
      weakToTypes: null,
      catalogIds: state.catalogIds,
      catalogCursor: state.catalogCursor + batch.length,
    );
  }

  Future<void> _loadCatalogInitial(
    PokemonListFilters filters,
    int generation,
  ) async {
    final weakToTypes = await _resolveWeakToTypes(filters);
    final sortedIds = await _resolveCandidateIds(filters);

    if (generation != _loadGeneration) return;

    if (sortedIds.isEmpty) {
      state = const PokemonListState(hasMore: false);
      return;
    }

    final batch = sortedIds.take(_catalogBatchSize).toList();

    await _loadBatchProgressive(
      ids: batch,
      generation: generation,
      lockedItems: const [],
      hasMore: sortedIds.length > batch.length,
      nextOffset: 0,
      filters: filters,
      weakToTypes: weakToTypes,
      catalogIds: sortedIds,
      catalogCursor: batch.length,
    );
  }

  Future<void> _loadCatalogMore(
    PokemonListFilters filters,
    int generation,
  ) async {
    final weakToTypes = await _resolveWeakToTypes(filters);
    final remaining = state.catalogIds.skip(state.catalogCursor).toList();
    final batch = remaining.take(_catalogBatchSize).toList();

    if (batch.isEmpty) {
      state = state.copyWith(isLoadingMore: false, hasMore: false);
      return;
    }

    await _loadBatchProgressive(
      ids: batch,
      generation: generation,
      lockedItems: state.items,
      hasMore: state.catalogCursor + batch.length < state.catalogIds.length,
      nextOffset: state.nextOffset,
      filters: filters,
      weakToTypes: weakToTypes,
      catalogIds: state.catalogIds,
      catalogCursor: state.catalogCursor + batch.length,
    );
  }

  Future<void> _loadBatchProgressive({
    required List<int> ids,
    required int generation,
    required List<PokemonSummary> lockedItems,
    required bool hasMore,
    required int nextOffset,
    required PokemonListFilters? filters,
    required Set<PokemonType>? weakToTypes,
    required List<int> catalogIds,
    required int catalogCursor,
  }) async {
    if (ids.isEmpty) {
      state = PokemonListState(
        items: lockedItems,
        hasMore: hasMore,
        nextOffset: nextOffset,
        catalogIds: catalogIds,
        catalogCursor: catalogCursor,
      );
      return;
    }

    state = PokemonListState(
      items: lockedItems,
      isLoadingSummaries: true,
      hasMore: hasMore,
      nextOffset: nextOffset,
      lockedItemCount: lockedItems.length,
      batchTarget: ids.length,
      catalogIds: catalogIds,
      catalogCursor: catalogCursor,
    );

    final processed = <int, PokemonSummary?>{};
    var nextIndex = 0;
    var visibleInBatch = 0;
    var publishScheduled = false;

    void publishNow() {
      if (generation != _loadGeneration) return;

      final batchVisible = _visibleFromBatch(
        ids: ids,
        processed: processed,
        filters: filters,
        weakToTypes: weakToTypes,
      );

      final processedCount = ids.where(processed.containsKey).length;

      if (batchVisible.length == visibleInBatch &&
          batchVisible.length < ids.length &&
          state.isLoadingSummaries) {
        return;
      }

      visibleInBatch = batchVisible.length;
      state = PokemonListState(
        items: [...lockedItems, ...batchVisible],
        isLoadingSummaries: processedCount < ids.length,
        hasMore: hasMore,
        nextOffset: nextOffset,
        lockedItemCount: lockedItems.length,
        batchTarget: ids.length,
        catalogIds: catalogIds,
        catalogCursor: catalogCursor,
      );
    }

    void publish() {
      if (publishScheduled) return;
      publishScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        publishScheduled = false;
        publishNow();
      });
    }

    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= ids.length) return;

        final id = ids[index];
        try {
          final summary = await _repository.getSummaryById(id);
          if (filters != null &&
              !PokemonListFilterUtils.apply(
                items: [summary],
                filters: filters,
                weakToTypes: weakToTypes,
              ).contains(summary)) {
            processed[id] = null;
          } else {
            processed[id] = summary;
          }
        } catch (_) {
          processed[id] = null;
        }

        publish();
      }
    }

    await Future.wait(List.generate(_concurrency, (_) => worker()));

    if (generation != _loadGeneration) return;

    publishScheduled = false;
    publishNow();

    final batchVisible = _visibleFromBatch(
      ids: ids,
      processed: processed,
      filters: filters,
      weakToTypes: weakToTypes,
    );

    state = PokemonListState(
      items: [...lockedItems, ...batchVisible],
      hasMore: hasMore,
      nextOffset: nextOffset,
      catalogIds: catalogIds,
      catalogCursor: catalogCursor,
    );
  }

  List<PokemonSummary> _visibleFromBatch({
    required List<int> ids,
    required Map<int, PokemonSummary?> processed,
    required PokemonListFilters? filters,
    required Set<PokemonType>? weakToTypes,
  }) {
    final visible = <PokemonSummary>[];
    for (final id in ids) {
      if (!processed.containsKey(id)) break;
      final summary = processed[id];
      if (summary != null) visible.add(summary);
    }
    return visible;
  }

  Future<List<int>> _resolveSearchOnlyIds(PokemonListFilters filters) async {
    final refs = await _repository.searchPokemonRefsByName(filters.searchQuery);
    final nameById = {for (final ref in refs) ref.id: ref.name};
    final ids = refs.map((ref) => ref.id).toList();
    return _sortIds(ids, filters.sort, nameById);
  }

  Future<List<int>> _resolveCandidateIds(PokemonListFilters filters) async {
    final allRefs = await _repository.getAllPokemonRefs();
    final nameById = {for (final ref in allRefs) ref.id: ref.name};

    List<int> ids;
    if (filters.generationId != null) {
      ids = await _repository.getPokemonIdsForGeneration(filters.generationId!);
    } else if (filters.typeFilter != null) {
      ids = await _repository.getPokemonIdsForTypes([filters.typeFilter!]);
    } else {
      ids = allRefs.map((ref) => ref.id).toList();
    }

    if (filters.hasSearch) {
      final searchRefs = await _repository.searchPokemonRefsByName(
        filters.searchQuery,
      );
      final matchingIds = searchRefs.map((ref) => ref.id).toSet();
      ids = ids.where(matchingIds.contains).toList();
    }

    return _sortIds(ids, filters.sort, nameById);
  }

  List<int> _sortIds(
    List<int> ids,
    PokemonSortOption sort,
    Map<int, String> nameById,
  ) {
    final sorted = List<int>.from(ids);
    switch (sort) {
      case PokemonSortOption.numberAsc:
        sorted.sort();
      case PokemonSortOption.numberDesc:
        sorted.sort((a, b) => b.compareTo(a));
      case PokemonSortOption.nameAsc:
        sorted.sort((a, b) => (nameById[a] ?? '').compareTo(nameById[b] ?? ''));
      case PokemonSortOption.nameDesc:
        sorted.sort((a, b) => (nameById[b] ?? '').compareTo(nameById[a] ?? ''));
    }
    return sorted;
  }

  Future<Set<PokemonType>?> _resolveWeakToTypes(
    PokemonListFilters filters,
  ) async {
    if (filters.weakness == null) return null;

    if (_weakToTypesFor == filters.weakness && _weakToTypesCache != null) {
      return _weakToTypesCache;
    }

    _weakToTypesFor = filters.weakness;
    _weakToTypesCache = await _repository.getTypesWeakTo(filters.weakness!);
    return _weakToTypesCache;
  }
}

final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
      final filtersNotifier = ref.watch(pokemonFiltersProvider.notifier);
      final notifier = PokemonListNotifier(
        ref.watch(pokemonRepositoryProvider),
        filtersNotifier,
      );

      ref.listen<PokemonListFilters>(pokemonFiltersProvider, (previous, next) {
        if (previous == next) return;
        notifier.reloadForFilters(next);
      });

      return notifier;
    });
