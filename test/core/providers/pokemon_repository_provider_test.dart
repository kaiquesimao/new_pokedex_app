import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OnlineConnectivity implements ConnectivityService {
  @override
  bool get isOnline => true;

  @override
  Stream<bool> get onlineStatus => Stream.value(true);

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> refresh() async => true;

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'pokemonRepositoryProvider keeps same instance when dio rebuilds',
    () async {
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
          appDatabaseProvider.overrideWithValue(db),
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'PokeData',
              packageName: 'pokedex_app',
              version: '1.0.0',
              buildNumber: '1',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final first = container.read(pokemonRepositoryProvider);
      await container.read(packageInfoProvider.future);
      container.read(dioProvider);
      final second = container.read(pokemonRepositoryProvider);

      expect(identical(first, second), isTrue);
    },
  );
}
