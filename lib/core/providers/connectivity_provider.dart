import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  throw UnimplementedError('Override connectivityServiceProvider in main.dart');
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).isOnline;
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onlineStatus;
});
