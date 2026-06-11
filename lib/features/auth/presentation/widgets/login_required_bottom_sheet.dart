import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';

Future<void> showLoginRequiredBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (context) => const _LoginRequiredBottomSheet(),
  );
}

class _LoginRequiredBottomSheet extends StatelessWidget {
  const _LoginRequiredBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Entre para salvar favoritos',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Entre para salvar favoritos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Crie uma conta ou entre para sincronizar seus Pokémon favoritos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Semantics(
              label: 'Entrar',
              button: true,
              child: AppButton(
                label: 'Entrar',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/login');
                },
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Criar conta',
              button: true,
              child: AppButton(
                label: 'Criar conta',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/register');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
