import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';

/// Applies global network policies when connectivity changes.
class NetworkAccessCoordinator {
  NetworkAccessCoordinator({
    required this._connectivity,
    required this._firebaseAvailable,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final ConnectivityService _connectivity;
  final bool _firebaseAvailable;
  final FirebaseFirestore _firestore;
  StreamSubscription<bool>? _subscription;

  Future<void> start() async {
    await _apply(_connectivity.isOnline);
    _subscription = _connectivity.onlineStatus.listen(_apply);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  Future<void> _apply(bool online) async {
    if (!_firebaseAvailable) return;

    try {
      if (online) {
        await _firestore.enableNetwork();
      } else {
        await _firestore.disableNetwork();
      }
    } catch (_) {
      // Firebase may not be ready on some platforms during tests.
    }
  }
}
