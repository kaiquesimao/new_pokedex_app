import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_cry_urls.dart';

enum PokemonCryPlayerStatus { idle, playing, error }

class PokemonCryPlayerState {
  const PokemonCryPlayerState({this.status = PokemonCryPlayerStatus.idle});

  final PokemonCryPlayerStatus status;
}

class PokemonCryPlayerNotifier extends Notifier<PokemonCryPlayerState> {
  AudioPlayer? _player;

  @override
  PokemonCryPlayerState build() {
    ref.onDispose(() {
      final player = _player;
      _player = null;
      if (player != null) {
        unawaited(player.stop());
        unawaited(player.dispose());
      }
    });
    return const PokemonCryPlayerState();
  }

  Future<void> playCry({
    String? cryUrl,
    String? legacyCryUrl,
    int? pokemonId,
  }) async {
    final urls = pokemonCryPlaybackUrls(
      cryUrl: cryUrl,
      legacyCryUrl: legacyCryUrl,
      pokemonId: pokemonId,
    );
    if (urls.isEmpty) {
      if (!ref.mounted) return;
      state = const PokemonCryPlayerState(
        status: PokemonCryPlayerStatus.error,
      );
      return;
    }

    _player ??= AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.stop);
    if (!ref.mounted) return;
    state = const PokemonCryPlayerState(status: PokemonCryPlayerStatus.playing);

    for (final url in urls) {
      try {
        await _player!.stop();
        await _player!.play(UrlSource(url, mimeType: 'audio/ogg'));
        if (!ref.mounted) return;
        state = const PokemonCryPlayerState();
        return;
      } on Object {
        continue;
      }
    }

    if (!ref.mounted) return;
    state = const PokemonCryPlayerState(status: PokemonCryPlayerStatus.error);
  }

  Future<void> stop() async {
    await _player?.stop();
    if (!ref.mounted) return;
    state = const PokemonCryPlayerState();
  }
}

final NotifierProvider<PokemonCryPlayerNotifier, PokemonCryPlayerState>
pokemonCryPlayerProvider =
    NotifierProvider<PokemonCryPlayerNotifier, PokemonCryPlayerState>(
      PokemonCryPlayerNotifier.new,
    );
