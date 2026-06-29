import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/riverpod.dart';

/// App version from platform package info, sourced from pubspec.yaml.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});
