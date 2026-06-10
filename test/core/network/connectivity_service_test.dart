import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';

class _FakeConnectivity implements Connectivity {
  _FakeConnectivity(this._results);

  List<ConnectivityResult> _results;

  void setResults(List<ConnectivityResult> results) {
    _results = results;
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

void main() {
  test(
    'reports online when plugin returns none but reachability succeeds',
    () async {
      final service = ConnectivityService(
        connectivity: _FakeConnectivity([ConnectivityResult.none]),
        reachabilityProbe: () async => true,
      );

      await service.initialize();

      expect(service.isOnline, isTrue);
    },
  );

  test('reports offline when plugin and reachability both fail', () async {
    final service = ConnectivityService(
      connectivity: _FakeConnectivity([ConnectivityResult.none]),
      reachabilityProbe: () async => false,
    );

    await service.initialize();

    expect(service.isOnline, isFalse);
  });

  test(
    'reports offline when interface exists but reachability fails',
    () async {
      final service = ConnectivityService(
        connectivity: _FakeConnectivity([ConnectivityResult.wifi]),
        reachabilityProbe: () async => false,
      );

      await service.initialize();

      expect(service.isOnline, isFalse);
    },
  );

  test(
    'reports online when interface exists and reachability succeeds',
    () async {
      final service = ConnectivityService(
        connectivity: _FakeConnectivity([ConnectivityResult.wifi]),
        reachabilityProbe: () async => true,
      );

      await service.initialize();

      expect(service.isOnline, isTrue);
    },
  );

  test(
    'treats empty plugin results as unknown interface, not offline',
    () async {
      final service = ConnectivityService(
        connectivity: _FakeConnectivity([]),
        reachabilityProbe: () async => true,
      );

      await service.initialize();

      expect(service.isOnline, isTrue);
    },
  );
}
