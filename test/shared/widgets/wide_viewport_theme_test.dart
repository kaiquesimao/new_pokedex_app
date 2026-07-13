import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/responsive_layout.dart';
import 'package:pokedex_app/shared/widgets/wide_viewport_backdrop.dart';

void main() {
  test('showsWideViewportBackdropFor only on wide web', () {
    expect(
      showsWideViewportBackdropFor(isWeb: true, width: 1200),
      isTrue,
    );
    expect(
      showsWideViewportBackdropFor(
        isWeb: true,
        width: ResponsiveLayout.maxContentWidth,
      ),
      isFalse,
    );
    expect(
      showsWideViewportBackdropFor(isWeb: false, width: 1200),
      isFalse,
    );
  });
}
