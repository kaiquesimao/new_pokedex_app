import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/router/page_transitions.dart';

void main() {
  test('push scrim stays opaque until the shell has left', () {
    expect(pushScrimOpacity(0), 1);
    expect(pushScrimOpacity(0.5), 1);
    expect(shellCoveredAmount(0.5, reversing: false), 1);
    expect(pushScrimOpacity(1), 0);
  });

  test('shell is gone halfway through the push and returns late on pop', () {
    expect(shellCoveredAmount(0, reversing: false), 0);
    expect(shellCoveredAmount(0.5, reversing: false), 1);
    expect(shellCoveredAmount(1, reversing: true), 1);
    expect(shellCoveredAmount(0.45, reversing: true), 1);
    expect(shellCoveredAmount(0, reversing: true), 0);
  });
}
