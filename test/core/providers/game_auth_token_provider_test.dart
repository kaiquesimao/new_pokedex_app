import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';

import '../../helpers/firebase_test_overrides.dart';

void main() {
  test('returns no token when Firebase is unavailable', () async {
    final container = ProviderContainer(
      overrides: [
        firebaseBootstrapProvider.overrideWithValue(kFirebaseUnavailable),
      ],
    );
    addTearDown(container.dispose);

    final token = await container
        .read(gameAuthTokenProvider)
        .call(forceRefresh: true);

    expect(token, isNull);
  });
}
