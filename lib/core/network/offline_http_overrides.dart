import 'dart:io';

import 'package:pokedex_app/core/network/connectivity_service.dart';

/// Blocks every [HttpClient] socket connection while the device is offline.
class OfflineHttpOverrides extends HttpOverrides {
  OfflineHttpOverrides(this.connectivity);

  final ConnectivityService connectivity;

  static const offlineMessage = 'Device is offline';

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    client.connectionFactory =
        (Uri url, String? proxyHost, int? proxyPort) async {
          if (!connectivity.isOnline) {
            throw const SocketException(offlineMessage);
          }

          final host = proxyHost ?? url.host;
          final port =
              proxyPort ??
              (url.hasPort
                  ? url.port
                  : url.scheme == 'https'
                  ? HttpClient.defaultHttpsPort
                  : HttpClient.defaultHttpPort);

          return Socket.startConnect(host, port);
        };

    return client;
  }
}
