import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

enum _ChangePasswordStep { current, newPassword, confirm, success }

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  _ChangePasswordStep _step = _ChangePasswordStep.current;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitCurrent() async {
    final value = _currentController.text;
    if (value.isEmpty) {
      setState(() => _error = 'Informe sua senha atual');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final valid = await ref
          .read(authProvider.notifier)
          .verifyCurrentPassword(value);
      if (!valid) {
        setState(() => _error = 'Senha atual incorreta');
        return;
      }
      setState(() => _step = _ChangePasswordStep.newPassword);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _submitNew() {
    final value = _newController.text;
    final passwordError = PasswordPolicy.validate(value);
    if (passwordError != null) {
      setState(() => _error = passwordError);
      return;
    }
    setState(() {
      _error = null;
      _step = _ChangePasswordStep.confirm;
    });
  }

  Future<void> _submitConfirm() async {
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    if (confirm != newPassword) {
      setState(() => _error = 'As senhas não coincidem');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(
            currentPassword: _currentController.text,
            newPassword: newPassword,
          );
      if (mounted) {
        setState(() => _step = _ChangePasswordStep.success);
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = formatAuthException(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goBackStep() {
    setState(() {
      _error = null;
      _step = switch (_step) {
        _ChangePasswordStep.newPassword => _ChangePasswordStep.current,
        _ChangePasswordStep.confirm => _ChangePasswordStep.newPassword,
        _ => _step,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        leading: _step == _ChangePasswordStep.success
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_step == _ChangePasswordStep.current) {
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
              if (_step != _ChangePasswordStep.success) ...[
                _StepIndicator(current: _stepIndex, total: 3),
                const SizedBox(height: 32),
                Text(
                  _headline,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              switch (_step) {
                _ChangePasswordStep.current => AppPasswordField(
                  label: 'Senha atual',
                  controller: _currentController,
                  errorText: _error,
                ),
                _ChangePasswordStep.newPassword => AppPasswordField(
                  label: 'Nova senha',
                  controller: _newController,
                  errorText: _error,
                ),
                _ChangePasswordStep.confirm => AppPasswordField(
                  label: 'Confirmar nova senha',
                  controller: _confirmController,
                  errorText: _error,
                ),
                _ChangePasswordStep.success => _SuccessBody(
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
              if (_step != _ChangePasswordStep.success) ...[
                const SizedBox(height: 32),
                AppButton(
                  label: _primaryButtonLabel,
                  isLoading: _loading,
                  onPressed: _loading ? null : _onPrimaryPressed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int get _stepIndex => switch (_step) {
    _ChangePasswordStep.current => 1,
    _ChangePasswordStep.newPassword => 2,
    _ChangePasswordStep.confirm => 3,
    _ChangePasswordStep.success => 3,
  };

  String get _appBarTitle => switch (_step) {
    _ChangePasswordStep.success => 'Senha alterada',
    _ => 'Trocar senha',
  };

  String get _headline => switch (_step) {
    _ChangePasswordStep.current => 'Qual é sua senha atual?',
    _ChangePasswordStep.newPassword => 'Crie uma nova senha',
    _ChangePasswordStep.confirm => 'Confirme a nova senha',
    _ChangePasswordStep.success => '',
  };

  String get _subtitle => switch (_step) {
    _ChangePasswordStep.current =>
      'Por segurança, confirme sua senha antes de continuar.',
    _ChangePasswordStep.newPassword => PasswordPolicy.requirementsHint,
    _ChangePasswordStep.confirm =>
      'Digite novamente a nova senha para confirmar.',
    _ChangePasswordStep.success => '',
  };

  String get _primaryButtonLabel => switch (_step) {
    _ChangePasswordStep.current => 'Continuar',
    _ChangePasswordStep.newPassword => 'Continuar',
    _ChangePasswordStep.confirm => 'Salvar senha',
    _ChangePasswordStep.success => 'Concluir',
  };

  VoidCallback? get _onPrimaryPressed => switch (_step) {
    _ChangePasswordStep.current => _submitCurrent,
    _ChangePasswordStep.newPassword => _submitNew,
    _ChangePasswordStep.confirm => _submitConfirm,
    _ChangePasswordStep.success => null,
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
