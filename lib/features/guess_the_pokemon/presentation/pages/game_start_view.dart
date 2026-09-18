import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Introductory view for starting a local or authenticated game.
class const GameStartView({
  required this.onStart,
  required this.onLeaderboard,
  super.key,
  this.errorMessage,
}) extends StatelessWidget {
  final Future<void> Function() onStart;
  final VoidCallback onLeaderboard;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.catching_pokemon, size: 72),
              const SizedBox(height: 20),
              Text(
                l10n.gameTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.gameGuestMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  errorMessage == null
                      ? l10n.gameStartButton
                      : l10n.gameRetryButton,
                ),
              ),
              TextButton(
                onPressed: onLeaderboard,
                child: Text(l10n.gameLeaderboardButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
