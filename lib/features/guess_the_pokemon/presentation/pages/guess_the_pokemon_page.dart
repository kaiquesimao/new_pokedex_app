import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/pages/game_result_view.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/pages/game_round_view.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/pages/game_start_view.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/guess_the_pokemon_providers.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:pokedex_app/shared/widgets/responsive_content_frame.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

/// Hosts the guessing game and projects controller state into its current view.
class const GuessThePokemonPage({super.key}) extends ConsumerWidget {
  /// Matches [AppBottomNavBar] floating chrome.
  static const _headerHorizontalInset = 16.0;
  static const _headerTopInset = 8.0;
  static const _headerCornerRadius = 20.0;
  static const _headerBarHeight = 56.0;
  static const _headerBottomGap = 8.0;

  static double get _headerOverlayHeight =>
      _headerTopInset + _headerBarHeight + _headerBottomGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guessThePokemonControllerProvider);
    final controller = ref.read(guessThePokemonControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final showAbandon =
        state.status == GuessThePokemonStatus.playing ||
        state.status == GuessThePokemonStatus.answering;

    return Scaffold(
      body: SafePageBody(
        bottom: false,
        child: ResponsiveContentFrame(
          expandHeight: true,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: _headerOverlayHeight,
                    bottom: AppBottomNavBar.overlayHeight(context),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_viewBucket(state.status)),
                      child: _buildView(context, ref, state),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _GameFloatingTitleBar(
                  title: l10n.gameTitle,
                  abandonTooltip: l10n.gameAbandonTooltip,
                  onAbandon: showAbandon
                      ? () => _confirmAbandon(context, controller)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Groups statuses that share the same view so AnimatedSwitcher does not
  /// remount the round screen when an answer is selected.
  static String _viewBucket(GuessThePokemonStatus status) {
    return switch (status) {
      GuessThePokemonStatus.playing ||
      GuessThePokemonStatus.answering => 'round',
      GuessThePokemonStatus.finished ||
      GuessThePokemonStatus.ranking => 'result',
      GuessThePokemonStatus.idle => 'idle',
      GuessThePokemonStatus.loading => 'loading',
      GuessThePokemonStatus.error => 'error',
    };
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
        spriteReady: state.spriteReady,
        selectedOptionId: state.selectedOptionId,
        lastAnswerCorrect: state.lastAnswerCorrect,
        revealedPokemonName: state.revealedPokemonName,
        revealedSpriteUrl: state.revealedSpriteUrl,
        secondsRemaining: state.secondsRemaining,
        timedOut: state.timedOut,
        error: state.error,
        onRetry: controller.retryAnswer,
        onAnswer: controller.selectAnswer,
        onSpriteReady: controller.onSpriteReady,
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
        timedOut: state.timedOut,
      ),
      GuessThePokemonStatus.error =>
        state.isRemote
            ? GameRoundView(
                localRound: state.localRound,
                remoteRound: state.remoteRound,
                score: state.score,
                spriteReady: state.spriteReady,
                selectedOptionId: state.selectedOptionId,
                lastAnswerCorrect: state.lastAnswerCorrect,
                revealedPokemonName: state.revealedPokemonName,
                revealedSpriteUrl: state.revealedSpriteUrl,
                error: state.error,
                onRetry: controller.retryAnswer,
                onAnswer: controller.selectAnswer,
                onSpriteReady: controller.onSpriteReady,
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

/// Floating title chrome aligned with [AppBottomNavBar] (inset + radius 20).
class const _GameFloatingTitleBar({
  required final String title,
  required final String abandonTooltip,
  final VoidCallback? onAbandon,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GuessThePokemonPage._headerHorizontalInset,
        GuessThePokemonPage._headerTopInset,
        GuessThePokemonPage._headerHorizontalInset,
        0,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
        borderRadius: BorderRadius.circular(
          GuessThePokemonPage._headerCornerRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: GuessThePokemonPage._headerBarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: onAbandon != null ? 48 : 16,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onAbandon != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: abandonTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: onAbandon,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
