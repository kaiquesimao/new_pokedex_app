import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tracks whether the device has a network interface available.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
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
    _isOnline = await _checkOnline();
    return _isOnline;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _statusController.close();
  }

  Future<bool> _checkOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online = _hasConnection(results);
    if (online == _isOnline) return;
    _isOnline = online;
    _statusController.add(_isOnline);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }
}
