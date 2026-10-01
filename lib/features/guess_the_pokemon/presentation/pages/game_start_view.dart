import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Introductory view for starting a local or authenticated game.
class const GameStartView({
  required final Future<void> Function() onStart,
  required final VoidCallback onLeaderboard,
  super.key,
  final String? errorMessage,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    // Fit inside the shell body without scroll; nav clearance is parent padding.
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.catching_pokemon, size: 72),
            if (!isAuthenticated) ...[
              const SizedBox(height: 20),
              Text(
                l10n.gameGuestMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  errorMessage == null
                      ? l10n.gameStartButton
                      : l10n.gameRetryButton,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
                onPressed: onLeaderboard,
                child: Text(l10n.gameLeaderboardButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
