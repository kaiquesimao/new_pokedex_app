import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/regions/data/models/region_models.dart';
import 'package:pokedex_app/features/regions/domain/repositories/region_repository.dart';

class RegionsNotifier extends AsyncNotifier<List<NamedApiResource>> {
  RegionRepository get _repository => ref.read(regionRepositoryProvider);

  @override
  Future<List<NamedApiResource>> build() async => [];

  Future<void> loadIfNeeded() async {
    if (state.hasValue && state.requireValue.isNotEmpty) return;
    await reload();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getRegions());
  }
}

final regionsProvider =
    AsyncNotifierProvider<RegionsNotifier, List<NamedApiResource>>(
      RegionsNotifier.new,
    );
