import 'dart:io';

import 'package:pokedex_app/core/network/connectivity_service.dart';

/// Blocks every [HttpClient] socket connection while the device is offline.
class OfflineHttpOverrides extends HttpOverrides {
  OfflineHttpOverrides(this.connectivity);

  final ConnectivityService connectivity;

  static const offlineMessage = 'Device is offline';

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    if (connectivity.isOnline) {
      return super.createHttpClient(context);
    }

    final client = super.createHttpClient(context);
    client.connectionFactory = (Uri url, String? proxyHost, int? proxyPort) {
      throw const SocketException(offlineMessage);
    };
    return client;
  }
}
