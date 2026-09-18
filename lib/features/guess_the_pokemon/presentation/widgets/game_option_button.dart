import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// A keyboard-focusable, semantically labelled answer control.
class const GameOptionButton({
  required this.name,
  super.key,
  this.onPressed,
}) extends StatelessWidget {
  final String name;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: l10n.gameAnswerSemantics(name),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              );
            }
            return null;
          }),
        ),
        child: Text(name, textAlign: TextAlign.center),
      ),
    );
  }
}
