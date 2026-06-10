import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/regions/data/models/region_models.dart';
import 'package:pokedex_app/features/regions/domain/repositories/region_repository.dart';

class RegionsNotifier
    extends StateNotifier<AsyncValue<List<NamedApiResource>>> {
  RegionsNotifier(this._repository) : super(const AsyncValue.data([]));

  final RegionRepository _repository;
  bool _started = false;

  Future<void> loadIfNeeded() async {
    if (_started) return;
    _started = true;
    await _fetch();
  }

  Future<void> reload() async {
    await _fetch();
  }

  Future<void> _fetch() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getRegions());
  }
}

final regionsProvider =
    StateNotifierProvider<RegionsNotifier, AsyncValue<List<NamedApiResource>>>((
      ref,
    ) {
      return RegionsNotifier(ref.watch(regionRepositoryProvider));
    });
