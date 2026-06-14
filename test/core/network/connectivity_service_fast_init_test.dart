import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';

class _FakeConnectivity implements Connectivity {
  const _FakeConnectivity(this._results);

  final List<ConnectivityResult> _results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

void main() {
  test('initialize returns before reachability probe completes', () async {
    final probeGate = Completer<void>();

    final service = ConnectivityService(
      connectivity: const _FakeConnectivity([ConnectivityResult.wifi]),
      reachabilityProbe: () async {
        await probeGate.future;
        return false;
      },
    );

    final stopwatch = Stopwatch()..start();
    await service.initialize();
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(500));
    expect(service.isOnline, isTrue);

    probeGate.complete();
    await service.refresh();
    expect(service.isOnline, isFalse);
  });
}
