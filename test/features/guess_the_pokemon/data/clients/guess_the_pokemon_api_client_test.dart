import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/network/guess_the_pokemon_api_client.dart';

void main() {
  final contract = jsonDecode(
    File('cloudflare/guess-the-pokemon/fixtures/game-contract.json')
        .readAsStringSync(),
  ) as Map<String, dynamic>;

  test('uses the configured game API base URL for every game route', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://worker.example.test'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                data: switch (options.path) {
                  '/v1/game/sessions' => contract['session'],
                  '/v1/game/sessions/session%2Fone/answers' =>
                    contract['answer'],
                   '/v1/leaderboards' => {
                    'entries': <Map<String, dynamic>>[],
                  },
                  _ => {'state': 'published'},
                },
              ),
            );
          },
        ),
      );
    final client = GuessThePokemonApiClient(dio);

    await client.startSession();
    await client.submitAnswer('session/one', const {
      'roundIndex': 1,
      'optionId': 25,
    });
    await client.getLeaderboard(scope: 'weekly', cursor: 'next');
     await client.updateGameProfile(
       isAnonymous: false,
       displayName: 'Ash',
     );
     await client.publishScore('session/one');

    expect(
      requests.map((request) => request.uri.toString()),
      [
        'https://worker.example.test/v1/game/sessions',
        'https://worker.example.test/v1/game/sessions/session%2Fone/answers',
         'https://worker.example.test/v1/leaderboards?scope=weekly&cursor=next',
        'https://worker.example.test/v1/me/game-profile',
         'https://worker.example.test/v1/game/sessions/session%2Fone/publish',
      ],
    );
    expect(requests[1].data, {'roundIndex': 1, 'optionId': 25});
  });

  test(
    'sends the public profile preference to the game profile endpoint',
    () async {
      RequestOptions? request;
      final dio = Dio(BaseOptions(baseUrl: 'https://worker.example.test'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              request = options;
              handler.resolve(
                Response(requestOptions: options, data: <String, dynamic>{}),
              );
            },
          ),
        );

       await GuessThePokemonApiClient(dio).updateGameProfile(
         isAnonymous: true,
         displayName: null,
       );

      expect(request?.method, 'PATCH');
      expect(request?.path, '/v1/me/game-profile');
       expect(request?.data, {'isAnonymous': true, 'displayName': null});
    },
  );

  test('empty game API configuration disables requests', () async {
    var requestCount = 0;
    final dio = Dio(BaseOptions(baseUrl: ''))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestCount++;
            handler.next(options);
          },
        ),
      );
    final client = GuessThePokemonApiClient(dio);

    await expectLater(
      client.startSession(),
      throwsA(isA<GameApiUnavailableException>()),
    );
    expect(requestCount, 0);
  });

  test(
    'adds a Firebase bearer token and refreshes it after unauthorized',
    () async {
      final tokenRefreshes = <bool>[];
      final authorizationHeaders = <String?>[];
      var requests = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://worker.example.test'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests++;
              authorizationHeaders.add(
                options.headers['Authorization'] as String?,
              );
              if (requests == 1) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      statusCode: 401,
                      requestOptions: options,
                    ),
                  ),
                );
                return;
              }
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: <String, dynamic>{'state': 'published'},
                ),
              );
            },
          ),
        );
      final client = GuessThePokemonApiClient(
        dio,
        tokenProvider: ({required forceRefresh}) async {
          tokenRefreshes.add(forceRefresh);
          return forceRefresh ? 'fresh-token' : 'cached-token';
        },
      );

       await client.publishScore('session-1');

      expect(tokenRefreshes, [false, true]);
      expect(authorizationHeaders, [
        'Bearer cached-token',
        'Bearer fresh-token',
      ]);
      expect(requests, 2);
    },
  );

  test(
    'publishes the anonymous display preference in the request body',
    () async {
      RequestOptions? request;
      final dio = Dio(BaseOptions(baseUrl: 'https://worker.example.test'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              request = options;
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: <String, dynamic>{'state': 'published'},
                ),
              );
            },
          ),
        );

       await GuessThePokemonApiClient(dio).publishScore('session-1');

       expect(request?.data, isNull);
    },
  );

  test(
    'rejects empty or padded session identifiers before requesting',
    () async {
      final client = GuessThePokemonApiClient(
        Dio(BaseOptions(baseUrl: 'https://worker.example.test')),
      );

      expect(
         () => client.publishScore(''),
        throwsArgumentError,
      );
      expect(
         () => client.publishScore(' session-1'),
        throwsArgumentError,
      );
    },
  );
}
