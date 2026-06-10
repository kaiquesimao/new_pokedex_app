import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokedex_entry.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokemon.dart';
import 'package:pokedex_app/features/regions/domain/repositories/region_repository.dart';

class RegionalPokedexState {
  const RegionalPokedexState({
    this.items = const [],
    this.isLoadingEntries = false,
    this.isLoadingSummaries = false,
    this.totalCount = 0,
    this.error,
    this.isOfflineMode = false,
  });

  final List<RegionalPokemon> items;
  final bool isLoadingEntries;
  final bool isLoadingSummaries;
  final int totalCount;
  final String? error;
  final bool isOfflineMode;

  bool get hasMore => items.length < totalCount;

  bool get showFullSkeleton =>
      items.isEmpty && (isLoadingEntries || isLoadingSummaries);

  RegionalPokedexState copyWith({
    List<RegionalPokemon>? items,
    bool? isLoadingEntries,
    bool? isLoadingSummaries,
    int? totalCount,
    String? error,
    bool? isOfflineMode,
    bool clearError = false,
  }) {
    return RegionalPokedexState(
      items: items ?? this.items,
      isLoadingEntries: isLoadingEntries ?? this.isLoadingEntries,
      isLoadingSummaries: isLoadingSummaries ?? this.isLoadingSummaries,
      totalCount: totalCount ?? this.totalCount,
      error: clearError ? null : (error ?? this.error),
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }
}

class RegionalPokedexNotifier extends StateNotifier<RegionalPokedexState> {
  RegionalPokedexNotifier(this._regionRepository, this._pokemonRepository)
    : super(const RegionalPokedexState());

  final RegionRepository _regionRepository;
  final PokemonRepository _pokemonRepository;

  static const int _concurrency = 8;
  int _loadGeneration = 0;

  Future<void> load(String regionName) async {
    final generation = ++_loadGeneration;

    state = const RegionalPokedexState(isLoadingEntries: true);

    try {
      final entries = await _regionRepository.getRegionalPokedexEntries(
        regionName,
      );
      final isOfflineMode = _regionRepository.takeOfflineFallbackUsed();

      if (generation != _loadGeneration) return;

      if (entries.isEmpty) {
        state = const RegionalPokedexState();
        return;
      }

      state = RegionalPokedexState(
        isLoadingSummaries: true,
        totalCount: entries.length,
        isOfflineMode: isOfflineMode,
      );

      await _loadSummariesProgressive(
        entries,
        generation,
        isOfflineMode: isOfflineMode,
      );
    } catch (error) {
      if (generation != _loadGeneration) return;
      state = RegionalPokedexState(
        error: friendlyErrorMessage(error),
        isOfflineMode: _regionRepository.takeOfflineFallbackUsed(),
      );
    }
  }

  Future<void> _loadSummariesProgressive(
    List<RegionalPokedexEntry> entries,
    int generation, {
    required bool isOfflineMode,
  }) async {
    final loaded = <int, RegionalPokemon>{};
    var nextIndex = 0;
    var visibleCount = 0;

    void publish() {
      if (generation != _loadGeneration) return;

      final visible = _contiguousPrefix(entries, loaded);
      if (visible.length == visibleCount &&
          visible.length < entries.length &&
          state.isLoadingSummaries) {
        return;
      }

      visibleCount = visible.length;
      state = RegionalPokedexState(
        items: visible,
        isLoadingSummaries: visible.length < entries.length,
        totalCount: entries.length,
        isOfflineMode:
            isOfflineMode || _pokemonRepository.takeOfflineFallbackUsed(),
      );
    }

    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= entries.length) return;

        final entry = entries[index];
        try {
          final summary = await _pokemonRepository.getSummaryById(
            entry.speciesId,
          );

          loaded[entry.entryNumber] = RegionalPokemon(
            regionalNumber: entry.entryNumber,
            pokemonId: entry.speciesId,
            name: summary.name,
            types: summary.types,
            spriteUrl: summary.spriteUrl,
          );
        } catch (_) {
          loaded[entry.entryNumber] = RegionalPokemon(
            regionalNumber: entry.entryNumber,
            pokemonId: entry.speciesId,
            name: entry.speciesName,
            types: const [],
          );
        }

        publish();
      }
    }

    await Future.wait(List.generate(_concurrency, (_) => worker()));

    if (generation != _loadGeneration) return;

    state = RegionalPokedexState(
      items: _contiguousPrefix(entries, loaded),
      totalCount: entries.length,
      isOfflineMode:
          isOfflineMode || _pokemonRepository.takeOfflineFallbackUsed(),
    );
  }

  List<RegionalPokemon> _contiguousPrefix(
    List<RegionalPokedexEntry> entries,
    Map<int, RegionalPokemon> loaded,
  ) {
    final visible = <RegionalPokemon>[];
    for (final entry in entries) {
      final pokemon = loaded[entry.entryNumber];
      if (pokemon == null) break;
      visible.add(pokemon);
    }
    return visible;
  }
}

final regionalPokedexProvider =
    StateNotifierProvider.family<
      RegionalPokedexNotifier,
      RegionalPokedexState,
      String
    >((ref, regionName) {
      final notifier = RegionalPokedexNotifier(
        ref.watch(regionRepositoryProvider),
        ref.watch(pokemonRepositoryProvider),
      );
      Future.microtask(() => notifier.load(regionName));
      return notifier;
    });
