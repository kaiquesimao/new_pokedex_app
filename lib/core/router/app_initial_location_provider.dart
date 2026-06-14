import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the first route resolved during cold-start bootstrap.
class AppInitialLocation {
  AppInitialLocation(this.value);

  String value;
}

final appInitialLocationHolderProvider = Provider<AppInitialLocation>(
  (ref) => AppInitialLocation('/welcome'),
);

final appInitialLocationProvider = Provider<String>(
  (ref) => ref.watch(appInitialLocationHolderProvider).value,
);
