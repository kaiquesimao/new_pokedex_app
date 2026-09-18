import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// A keyboard-focusable, semantically labelled answer control.
class const GameOptionButton({
  required this.name,
  super.key,
  this.onPressed,
  this.selected = false,
  this.correct,
}) extends StatelessWidget {
  final String name;
  final VoidCallback? onPressed;
  final bool selected;
  final bool? correct;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final Color? background = switch (correct) {
      true => scheme.primaryContainer,
      false when selected => scheme.errorContainer,
      _ when selected => scheme.secondaryContainer,
      _ => null,
    };
    final Color? foreground = switch (correct) {
      true => scheme.onPrimaryContainer,
      false when selected => scheme.onErrorContainer,
      _ => null,
    };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: l10n.gameAnswerSemantics(name),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: background == null
              ? null
              : WidgetStatePropertyAll(background),
          foregroundColor: foreground == null
              ? null
              : WidgetStatePropertyAll(foreground),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (correct == true) {
              return BorderSide(color: scheme.primary, width: 2);
            }
            if (correct == false && selected) {
              return BorderSide(color: scheme.error, width: 2);
            }
            if (states.contains(WidgetState.focused) || selected) {
              return BorderSide(color: scheme.primary, width: 3);
            }
            return null;
          }),
        ),
        child: Text(name, textAlign: TextAlign.center),
      ),
    );
  }
}
