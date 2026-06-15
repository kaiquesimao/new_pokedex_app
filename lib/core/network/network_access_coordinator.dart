import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';

/// Applies global network policies when connectivity changes.
class NetworkAccessCoordinator {
  NetworkAccessCoordinator({
    required this._connectivity,
    required this._firebaseAvailable,
    this._firestore,
  });

  final ConnectivityService _connectivity;
  final bool _firebaseAvailable;
  final FirebaseFirestore? _firestore;
  StreamSubscription<bool>? _subscription;

  Future<void> start() async {
    await _apply(_connectivity.isOnline);
    _subscription = _connectivity.onlineStatus.listen(_scheduleApply);
  }

  void _scheduleApply(bool online) {
    unawaited(
      _apply(online).catchError((_) {
        // Firebase may not be ready on some platforms during tests.
      }),
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  Future<void> _apply(bool online) async {
    // Firestore network toggling targets mobile offline persistence only.
    if (!_firebaseAvailable || kIsWeb) return;

    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      if (online) {
        await firestore.enableNetwork();
      } else {
        await firestore.disableNetwork();
      }
    } catch (_) {
      // Firebase may not be ready on some platforms during tests.
    }
  }
}
