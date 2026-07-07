import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/domain/auth_account_policy.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/change_password_flow_provider.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitCurrent() async {
    await ref
        .read(changePasswordFlowProvider.notifier)
        .submitCurrent(_currentController.text);
  }

  void _submitNew() {
    ref
        .read(changePasswordFlowProvider.notifier)
        .submitNew(_newController.text);
  }

  Future<void> _submitConfirm() async {
    await ref
        .read(changePasswordFlowProvider.notifier)
        .submitConfirm(
          newPassword: _newController.text,
          confirmPassword: _confirmController.text,
        );
  }

  void _goBackStep() {
    ref.read(changePasswordFlowProvider.notifier).goBackStep();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (!auth.canEditCredentials) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(socialAccountCredentialsMessage)),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final flow = ref.watch(changePasswordFlowProvider);
    final step = flow.step;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(step)),
        leading: step == ChangePasswordStep.success
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (step == ChangePasswordStep.current) {
                    context.pop();
                  } else {
                    _goBackStep();
                  }
                },
              ),
      ),
      body: SafePageBody.belowAppBar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (step != ChangePasswordStep.success) ...[
                _StepIndicator(current: _stepIndex(step), total: 3),
                const SizedBox(height: 32),
                Text(
                  _headline(step),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle(step),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              switch (step) {
                ChangePasswordStep.current => AppPasswordField(
                  label: 'Senha atual',
                  controller: _currentController,
                  errorText: flow.error,
                ),
                ChangePasswordStep.newPassword => AppPasswordField(
                  label: 'Nova senha',
                  controller: _newController,
                  errorText: flow.error,
                ),
                ChangePasswordStep.confirm => AppPasswordField(
                  label: 'Confirmar nova senha',
                  controller: _confirmController,
                  errorText: flow.error,
                ),
                ChangePasswordStep.success => _SuccessBody(
                  onDone: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ação realizada com sucesso'),
                        backgroundColor: AppColorsLight.primary,
                      ),
                    );
                    context.pop();
                  },
                ),
              },
              if (step != ChangePasswordStep.success) ...[
                const SizedBox(height: 32),
                AppButton(
                  label: _primaryButtonLabel(step),
                  isLoading: flow.loading,
                  onPressed: flow.loading ? null : _onPrimaryPressed(step),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _stepIndex(ChangePasswordStep step) => switch (step) {
    ChangePasswordStep.current => 1,
    ChangePasswordStep.newPassword => 2,
    ChangePasswordStep.confirm => 3,
    ChangePasswordStep.success => 3,
  };

  String _appBarTitle(ChangePasswordStep step) => switch (step) {
    ChangePasswordStep.success => 'Senha alterada',
    _ => 'Trocar senha',
  };

  String _headline(ChangePasswordStep step) => switch (step) {
    ChangePasswordStep.current => 'Qual é sua senha atual?',
    ChangePasswordStep.newPassword => 'Crie uma nova senha',
    ChangePasswordStep.confirm => 'Confirme a nova senha',
    ChangePasswordStep.success => '',
  };

  String _subtitle(ChangePasswordStep step) => switch (step) {
    ChangePasswordStep.current =>
      'Por segurança, confirme sua senha antes de continuar.',
    ChangePasswordStep.newPassword => PasswordPolicy.requirementsHint,
    ChangePasswordStep.confirm =>
      'Digite novamente a nova senha para confirmar.',
    ChangePasswordStep.success => '',
  };

  String _primaryButtonLabel(ChangePasswordStep step) => switch (step) {
    ChangePasswordStep.current => 'Continuar',
    ChangePasswordStep.newPassword => 'Continuar',
    ChangePasswordStep.confirm => 'Salvar senha',
    ChangePasswordStep.success => 'Concluir',
  };

  VoidCallback? _onPrimaryPressed(ChangePasswordStep step) => switch (step) {
    ChangePasswordStep.current => _submitCurrent,
    ChangePasswordStep.newPassword => _submitNew,
    ChangePasswordStep.confirm => _submitConfirm,
    ChangePasswordStep.success => null,
  };
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final active = index < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Senha alterada com sucesso!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sua nova senha já está ativa. Use-a no próximo login.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        AppButton(label: 'Voltar à conta', onPressed: onDone),
      ],
    );
  }
}
