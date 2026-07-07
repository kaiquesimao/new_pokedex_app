import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/legal/presentation/providers/legal_acceptance_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

bool canProceedWithLegal(WidgetRef ref) {
  return ref.read(legalAcceptanceProvider) ||
      ref.read(legalAcceptanceDraftProvider);
}

Future<bool> ensureLegalAccepted(BuildContext context, WidgetRef ref) async {
  if (ref.read(legalAcceptanceProvider)) return true;

  if (!ref.read(legalAcceptanceDraftProvider)) {
    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authLegalAcceptTerms)),
      );
    }
    return false;
  }

  await ref.read(legalAcceptanceProvider.notifier).accept();
  return true;
}

/// Checkbox with links to legal pages. Hidden when terms were already accepted.
class LegalAcceptanceField extends ConsumerWidget {
  const LegalAcceptanceField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accepted = ref.watch(legalAcceptanceProvider);
    if (accepted) return const SizedBox.shrink();

    final checked = ref.watch(legalAcceptanceDraftProvider);

    return LegalAcceptanceCheckbox(
      value: checked,
      onChanged: (value) {
        ref
            .read(legalAcceptanceDraftProvider.notifier)
            .setChecked(value: value);
      },
    );
  }
}

class LegalAcceptanceCheckbox extends StatelessWidget {
  const LegalAcceptanceCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    final label = _LegalLabel(theme: theme, linkStyle: linkStyle, l10n: l10n);

    final row = Row(
      mainAxisSize: kIsWeb ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: (checked) => onChanged(checked ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        if (kIsWeb)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: label,
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: label,
            ),
          ),
      ],
    );

    if (kIsWeb) {
      return Align(child: row);
    }
    return row;
  }
}

class _LegalLabel extends StatelessWidget {
  const _LegalLabel({
    required this.theme,
    required this.linkStyle,
    required this.l10n,
  });

  final ThemeData theme;
  final TextStyle? linkStyle;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.legalAcceptPrefix, style: theme.textTheme.bodySmall),
        _LegalLink(
          label: l10n.profileTermsLabel,
          style: linkStyle,
          onTap: () => context.push('/legal/terms'),
        ),
        Text(l10n.legalAcceptMiddle, style: theme.textTheme.bodySmall),
        _LegalLink(
          label: l10n.profilePrivacyLabel,
          style: linkStyle,
          onTap: () => context.push('/legal/privacy'),
        ),
        Text('.', style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle? style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: style),
    );
  }
}
