import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/legal/presentation/providers/legal_acceptance_provider.dart';

bool canProceedWithLegal(WidgetRef ref) {
  return ref.read(legalAcceptanceProvider) ||
      ref.read(legalAcceptanceDraftProvider);
}

Future<bool> ensureLegalAccepted(BuildContext context, WidgetRef ref) async {
  if (ref.read(legalAcceptanceProvider)) return true;

  if (!ref.read(legalAcceptanceDraftProvider)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aceite os Termos de uso e a Política de privacidade para continuar.',
          ),
        ),
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
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: (checked) => onChanged(checked ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Li e aceito os ', style: theme.textTheme.bodySmall),
                _LegalLink(
                  label: 'Termos de uso',
                  style: linkStyle,
                  onTap: () => context.push('/legal/terms'),
                ),
                Text(' e a ', style: theme.textTheme.bodySmall),
                _LegalLink(
                  label: 'Política de privacidade',
                  style: linkStyle,
                  onTap: () => context.push('/legal/privacy'),
                ),
                Text('.', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
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
