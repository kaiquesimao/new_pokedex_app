import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/leaderboard_provider.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/widgets/leaderboard_entry_tile.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class const LeaderboardPage({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(leaderboardProvider.notifier).load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardProvider);
    final auth = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leaderboardTitle)),
      body: SafePageBody.belowAppBar(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 240) {
              unawaited(ref.read(leaderboardProvider.notifier).loadMore());
            }
            return false;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _ScopeToggle(
                scope: state.scope,
                onChanged: (scope) => unawaited(
                  ref.read(leaderboardProvider.notifier).load(scope: scope),
                ),
              ),
              if (!auth.isAuthenticated) ...[
                const SizedBox(height: 16),
                _GuestGuidance(onSignIn: () => context.push('/login')),
              ],
              const SizedBox(height: 20),
              if (state.status == LeaderboardStatus.loading &&
                  state.entries.isEmpty)
                const Center(child: CircularProgressIndicator.adaptive())
              else if (state.status == LeaderboardStatus.error &&
                  state.entries.isEmpty)
                _ErrorState(
                  isOffline: _isOffline(state.error),
                  onRetry: () => unawaited(
                    ref
                        .read(leaderboardProvider.notifier)
                        .load(scope: state.scope),
                  ),
                )
              else if (state.entries.isEmpty)
                Center(child: Text(l10n.leaderboardEmpty))
              else
                for (var index = 0; index < state.entries.length; index++)
                  _entryTile(state.entries[index], index),
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entryTile(LeaderboardEntryModel entry, int index) {
    return LeaderboardEntryTile(
      rank: entry.rank > 0 ? entry.rank : index + 1,
      playerName: entry.playerName,
      score: entry.score,
      isCurrentUser: entry.isCurrentUser,
    );
  }

  bool _isOffline(Object? error) =>
      error is GuessThePokemonException &&
      (error.code == GuessThePokemonErrorCode.network ||
          error.code == GuessThePokemonErrorCode.unavailable);
}

class const _ScopeToggle({required final LeaderboardScope scope, required final ValueChanged<LeaderboardScope> onChanged})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<LeaderboardScope>(
      segments: [
        ButtonSegment(
          value: LeaderboardScope.general,
          label: Text(l10n.leaderboardGeneralTab),
        ),
        ButtonSegment(
          value: LeaderboardScope.weekly,
          label: Text(l10n.leaderboardWeeklyTab),
        ),
      ],
      selected: {scope},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class const _GuestGuidance({required final VoidCallback onSignIn}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.leaderboardSignInGuidance),
            const SizedBox(height: 12),
            AppButton(label: l10n.authLoginRequiredSignIn, onPressed: onSignIn),
          ],
        ),
      ),
    );
  }
}

class const _ErrorState({required final bool isOffline, required final VoidCallback onRetry})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(isOffline ? l10n.leaderboardOffline : l10n.leaderboardError),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: Text(l10n.leaderboardRetry)),
      ],
    );
  }
}
