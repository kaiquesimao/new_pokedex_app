import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/pages/game_result_view.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/pages/game_round_view.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/pages/game_start_view.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/guess_the_pokemon_providers.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/responsive_content_frame.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

/// Hosts the guessing game and projects controller state into its current view.
class const GuessThePokemonPage({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guessThePokemonControllerProvider);
    final controller = ref.read(guessThePokemonControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.gameTitle),
        actions: [
          if (state.status == GuessThePokemonStatus.playing ||
              state.status == GuessThePokemonStatus.answering)
            IconButton(
              tooltip: l10n.gameAbandonTooltip,
              icon: const Icon(Icons.close),
              onPressed: () => _confirmAbandon(context, controller),
            ),
        ],
      ),
      body: SafePageBody.belowAppBar(
        child: ResponsiveContentFrame(
          expandHeight: true,
          child: _buildView(context, ref, state),
        ),
      ),
    );
  }

  Widget _buildView(
    BuildContext context,
    WidgetRef ref,
    GuessThePokemonState state,
  ) {
    final controller = ref.read(guessThePokemonControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return switch (state.status) {
      GuessThePokemonStatus.idle => GameStartView(
        onStart: controller.start,
        onLeaderboard: () => context.push('/leaderboard'),
      ),
      GuessThePokemonStatus.loading => Center(
        child: Semantics(
          label: l10n.gameLoading,
          child: const CircularProgressIndicator.adaptive(),
        ),
      ),
      GuessThePokemonStatus.playing ||
      GuessThePokemonStatus.answering => GameRoundView(
        localRound: state.localRound,
        remoteRound: state.remoteRound,
        score: state.score,
        isAnswering: state.status == GuessThePokemonStatus.answering,
        selectedOptionId: state.selectedOptionId,
        lastAnswerCorrect: state.lastAnswerCorrect,
        revealedPokemonName: state.revealedPokemonName,
        revealedSpriteUrl: state.revealedSpriteUrl,
        error: state.error,
        onRetry: controller.retryAnswer,
        onAnswer: controller.selectAnswer,
      ),
      GuessThePokemonStatus.finished => GameResultView(
        score: state.score,
        bestScore: state.bestScore,
        canPublish: state.canPublish,
        publicationState: state.publicationState,
        onPlayAgain: controller.playAgain,
        onLeaderboard: () => context.push('/leaderboard'),
        onPublish: controller.retryPublication,
        localRound: state.localRound,
        remoteRound: state.remoteRound,
        revealedPokemonName: state.revealedPokemonName,
        revealedSpriteUrl: state.revealedSpriteUrl,
        lastAnswerCorrect: state.lastAnswerCorrect,
      ),
      GuessThePokemonStatus.error => state.isRemote
          ? GameRoundView(
              localRound: state.localRound,
              remoteRound: state.remoteRound,
              score: state.score,
              selectedOptionId: state.selectedOptionId,
              lastAnswerCorrect: state.lastAnswerCorrect,
              revealedPokemonName: state.revealedPokemonName,
              revealedSpriteUrl: state.revealedSpriteUrl,
              error: state.error,
              onRetry: controller.retryAnswer,
              onAnswer: controller.selectAnswer,
            )
          : GameStartView(
              errorMessage: l10n.gameError,
              onStart: controller.start,
              onLeaderboard: () => context.push('/leaderboard'),
            ),
      GuessThePokemonStatus.ranking => GameResultView(
        score: state.score,
        bestScore: state.bestScore,
        canPublish: false,
        publicationState: PublicationState.published,
        onPlayAgain: controller.playAgain,
        onLeaderboard: () => context.push('/leaderboard'),
      ),
    };
  }

  Future<void> _confirmAbandon(
    BuildContext context,
    GuessThePokemonController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final shouldAbandon = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.gameAbandonTitle),
        content: Text(l10n.gameAbandonMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.gameKeepPlayingButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.gameAbandonButton),
          ),
        ],
      ),
    );
    if (shouldAbandon == true) controller.abandon();
  }
}
