import 'dart:async';
import 'dart:io';

Future<bool> probeInternetReachability() async {
  const hosts = ['pokeapi.co', 'one.one.one.one'];

  for (final host in hosts) {
    try {
      final result = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        return true;
      }
    } on Object {
      continue;
    }
  }

  return false;
}
