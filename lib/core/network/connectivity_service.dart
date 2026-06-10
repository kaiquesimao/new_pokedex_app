import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pokedex_app/core/network/connectivity_reachability.dart';

/// Tracks whether the device can reach the network.
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    Future<bool> Function()? reachabilityProbe,
  }) : _connectivity = connectivity ?? Connectivity(),
       _reachabilityProbe = reachabilityProbe ?? probeInternetReachability;

  final Connectivity _connectivity;
  final Future<bool> Function() _reachabilityProbe;
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Stream<bool> get onlineStatus async* {
    yield _isOnline;
    yield* _statusController.stream;
  }

  Future<void> initialize() async {
    _isOnline = await _checkOnline();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  Future<bool> refresh() async {
    final online = await _checkOnline();
    if (online != _isOnline) {
      _isOnline = online;
      if (!_statusController.isClosed) {
        _statusController.add(_isOnline);
      }
    } else {
      _isOnline = online;
    }
    return _isOnline;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _statusController.close();
  }

  Future<bool> _checkOnline() async {
    final results = await _connectivity.checkConnectivity();
    final hasInterface = _hasNetworkInterface(results);

    if (kIsWeb) {
      return hasInterface;
    }

    final reachable = await _reachabilityProbe();
    if (reachable) return true;

    return hasInterface && reachable;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    unawaited(_refreshFromConnectivityChange(results));
  }

  Future<void> _refreshFromConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final online = await _resolveOnlineStatus(results);
    if (online == _isOnline) return;
    _isOnline = online;
    _statusController.add(_isOnline);
  }

  Future<bool> _resolveOnlineStatus(List<ConnectivityResult> results) async {
    final hasInterface = _hasNetworkInterface(results);

    if (kIsWeb) {
      return hasInterface;
    }

    final reachable = await _reachabilityProbe();
    if (reachable) return true;

    return hasInterface && reachable;
  }

  bool _hasNetworkInterface(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.any((result) => result != ConnectivityResult.none);
  }
}
