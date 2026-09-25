import 'package:dio/dio.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/network/network_errors.dart';

typedef GameAuthTokenProvider = Future<String?> Function({
  required bool forceRefresh,
});

/// HTTP client for the game Worker API, separate from PokéAPI.
class GuessThePokemonApiClient {
  new(this._dio, {this.tokenProvider});

  final Dio _dio;
  final GameAuthTokenProvider? tokenProvider;

  bool get isConfigured => _dio.options.baseUrl.trim().isNotEmpty;

  Future<Map<String, dynamic>> startSession() async {
    _ensureConfigured();
    try {
      final response = await _request(
        (headers) => _dio.post<Map<String, dynamic>>(
          '/v1/game/sessions',
          options: _options(headers),
        ),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      mapDioException(error, loadTarget: ApiLoadTarget.guessThePokemon);
    }
  }

  Future<Map<String, dynamic>> submitAnswer(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    _ensureConfigured();
    final encodedSessionId = _encodeSessionId(sessionId);
    try {
      final response = await _request(
        (headers) => _dio.post<Map<String, dynamic>>(
          '/v1/game/sessions/$encodedSessionId/answers',
          data: data,
          options: _options(headers),
        ),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      mapDioException(error, loadTarget: ApiLoadTarget.guessThePokemon);
    }
  }

  Future<Map<String, dynamic>> getLeaderboard({
    required String scope,
    String? cursor,
  }) async {
    _ensureConfigured();
    try {
      final response = await _request(
        (headers) => _dio.get<Map<String, dynamic>>(
          '/v1/leaderboards',
          queryParameters: {'scope': scope, 'cursor': ?cursor},
          options: _options(headers),
        ),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      mapDioException(error, loadTarget: ApiLoadTarget.guessThePokemon);
    }
  }

  Future<Map<String, dynamic>> publishScore(String sessionId) async {
    _ensureConfigured();
    final encodedSessionId = _encodeSessionId(sessionId);
    try {
      final response = await _request(
        (headers) => _dio.post<Map<String, dynamic>>(
          '/v1/game/sessions/$encodedSessionId/publish',
          options: _options(headers),
        ),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      mapDioException(error, loadTarget: ApiLoadTarget.guessThePokemon);
    }
  }

  Future<Map<String, dynamic>> updateGameProfile({
    required bool isAnonymous,
    required String? displayName,
  }) async {
    _ensureConfigured();
    try {
      final response = await _request(
        (headers) => _dio.patch<Map<String, dynamic>>(
          '/v1/me/game-profile',
          data: {'isAnonymous': isAnonymous, 'displayName': displayName},
          options: _options(headers),
        ),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      mapDioException(error, loadTarget: ApiLoadTarget.guessThePokemon);
    }
  }

  Future<Map<String, dynamic>> getGameProfile() async {
    _ensureConfigured();
    try {
      final response = await _request(
        (headers) => _dio.get<Map<String, dynamic>>(
          '/v1/me/game-profile',
          options: _options(headers),
        ),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      mapDioException(error, loadTarget: ApiLoadTarget.guessThePokemon);
    }
  }

  Future<Response<T>> _request<T>(
    Future<Response<T>> Function(Map<String, String> headers) request,
  ) async {
    var forceRefresh = false;
    while (true) {
      try {
        return await request(await _authorizationHeaders(forceRefresh));
      } on DioException catch (error) {
        if (tokenProvider != null &&
            error.response?.statusCode == 401 &&
            !forceRefresh) {
          forceRefresh = true;
          continue;
        }
        rethrow;
      }
    }
  }

  Future<Map<String, String>> _authorizationHeaders(bool forceRefresh) async {
    final token = await tokenProvider?.call(forceRefresh: forceRefresh);
    return token == null || token.isEmpty
        ? const {}
        : {'Authorization': 'Bearer $token'};
  }

  Options _options(Map<String, String> headers) => Options(headers: headers);

  void _ensureConfigured() {
    if (!isConfigured) throw const GameApiUnavailableException();
  }

  String _encodeSessionId(String sessionId) {
    final value = sessionId.trim();
    if (value.isEmpty || value != sessionId) {
      throw ArgumentError.value(sessionId, 'sessionId', 'Must be non-empty');
    }
    return Uri.encodeComponent(value);
  }
}
