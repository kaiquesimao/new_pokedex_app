import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/crash_reporting/crash_platform.dart';

void main() {
  test('VM unit tests report native runtime (not web)', () {
    expect(resolveCrashPlatform(), isNot(equals('web')));
    expect(resolveCrashRuntime(), 'native');
  });
}
