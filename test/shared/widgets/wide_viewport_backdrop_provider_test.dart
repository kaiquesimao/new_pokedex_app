import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/wide_viewport_backdrop_assets.dart';
import 'package:pokedex_app/shared/widgets/wide_viewport_backdrop_provider.dart';

void main() {
  test('backdrop assets list is not empty', () {
    expect(WideViewportBackdropAssets.paths, isNotEmpty);
  });

  test('randomWideViewportBackdropIndex avoids exclude when possible', () {
    final length = WideViewportBackdropAssets.paths.length;
    if (length <= 1) return;

    for (var i = 0; i < length; i++) {
      final next = randomWideViewportBackdropIndex(exclude: i);
      expect(next, isNot(equals(i)));
    }
  });

  test('advance cycles through indices', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(wideViewportBackdropIndexProvider.notifier);
    final start = container.read(wideViewportBackdropIndexProvider);
    notifier.advance();

    final next = container.read(wideViewportBackdropIndexProvider);
    expect(next, (start + 1) % WideViewportBackdropAssets.paths.length);
  });
}
