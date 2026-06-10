import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/otp_code_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

enum _ForgotPasswordStep { email, otp, newPassword, success, emailSent }

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _ForgotPasswordStep _step = _ForgotPasswordStep.email;
  String? _error;
  bool _loading = false;
  var _resent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Informe um e-mail válido');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final usesFirebase = ref.read(firebaseBootstrapProvider).isAvailable;
      if (usesFirebase) {
        await ref
            .read(authProvider.notifier)
            .sendPasswordResetEmail(email: email);
        if (mounted) setState(() => _step = _ForgotPasswordStep.emailSent);
      } else {
        await ref.read(authProvider.notifier).sendOtp(email: email);
        if (mounted) setState(() => _step = _ForgotPasswordStep.otp);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp(String code) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final valid = await ref
          .read(authProvider.notifier)
          .verifyOtp(email: _emailController.text.trim(), code: code);

      if (!valid) {
        setState(() => _error = 'Código inválido. Tente novamente.');
        return;
      }

      if (mounted) setState(() => _step = _ForgotPasswordStep.newPassword);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    await ref
        .read(authProvider.notifier)
        .sendOtp(email: _emailController.text.trim());
    if (mounted) {
      setState(() => _resent = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código reenviado (mock)')));
    }
  }

  Future<void> _submitNewPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      setState(() => _error = 'A senha deve ter pelo menos 6 caracteres');
      return;
    }

    if (password != confirm) {
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
          .resetPassword(
            email: _emailController.text.trim(),
            newPassword: password,
          );
      if (mounted) setState(() => _step = _ForgotPasswordStep.success);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goBackStep() {
    setState(() {
      _error = null;
      _step = switch (_step) {
        _ForgotPasswordStep.otp => _ForgotPasswordStep.email,
        _ForgotPasswordStep.newPassword => _ForgotPasswordStep.otp,
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
        leading:
            _step == _ForgotPasswordStep.success ||
                _step == _ForgotPasswordStep.emailSent
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_step == _ForgotPasswordStep.email) {
                    context.pop();
                  } else {
                    _goBackStep();
                  }
                },
              ),
      ),
      body: Stack(
        children: [
          SafePageBody.belowAppBar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_step != _ForgotPasswordStep.success &&
                      _step != _ForgotPasswordStep.emailSent) ...[
                    if (_step != _ForgotPasswordStep.otp)
                      _StepIndicator(current: _stepIndex, total: 3),
                    if (_step != _ForgotPasswordStep.otp)
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
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  switch (_step) {
                    _ForgotPasswordStep.email => AppTextField(
                      label: 'E-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _error,
                    ),
                    _ForgotPasswordStep.otp => OtpCodeField(
                      errorText: _error,
                      onCompleted: _verifyOtp,
                      onResend: _resendOtp,
                    ),
                    _ForgotPasswordStep.newPassword => Column(
                      children: [
                        AppPasswordField(
                          label: 'Nova senha',
                          controller: _passwordController,
                          errorText: _error,
                        ),
                        const SizedBox(height: 16),
                        AppPasswordField(
                          label: 'Confirmar nova senha',
                          controller: _confirmController,
                        ),
                      ],
                    ),
                    _ForgotPasswordStep.success => _SuccessBody(
                      onDone: () => context.go('/login/email'),
                    ),
                    _ForgotPasswordStep.emailSent => _EmailSentBody(
                      email: _emailController.text.trim(),
                      onDone: () => context.go('/login/email'),
                    ),
                  },
                  if (_step == _ForgotPasswordStep.otp && _resent) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Um novo código foi enviado.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_step == _ForgotPasswordStep.email ||
                      _step == _ForgotPasswordStep.newPassword) ...[
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
          if (_loading &&
              _step != _ForgotPasswordStep.success &&
              _step != _ForgotPasswordStep.emailSent)
            const AuthLoadingOverlay(message: 'Processando...'),
        ],
      ),
    );
  }

  int get _stepIndex => switch (_step) {
    _ForgotPasswordStep.email => 1,
    _ForgotPasswordStep.otp => 2,
    _ForgotPasswordStep.newPassword => 3,
    _ForgotPasswordStep.success => 3,
    _ForgotPasswordStep.emailSent => 3,
  };

  String get _appBarTitle => switch (_step) {
    _ForgotPasswordStep.success => 'Senha redefinida',
    _ForgotPasswordStep.emailSent => 'E-mail enviado',
    _ => 'Recuperar senha',
  };

  String get _headline => switch (_step) {
    _ForgotPasswordStep.email => 'Esqueceu sua senha?',
    _ForgotPasswordStep.otp => 'Confirme o código',
    _ForgotPasswordStep.newPassword => 'Crie uma nova senha',
    _ForgotPasswordStep.success => '',
    _ForgotPasswordStep.emailSent => '',
  };

  String get _subtitle => switch (_step) {
    _ForgotPasswordStep.email =>
      'Informe seu e-mail para receber um código de verificação.',
    _ForgotPasswordStep.otp =>
      'Digite o código de 6 dígitos enviado para ${_emailController.text.trim()}.',
    _ForgotPasswordStep.newPassword =>
      'Use pelo menos 6 caracteres para proteger sua conta.',
    _ForgotPasswordStep.success => '',
    _ForgotPasswordStep.emailSent => '',
  };

  String get _primaryButtonLabel => switch (_step) {
    _ForgotPasswordStep.email => 'Enviar código',
    _ForgotPasswordStep.newPassword => 'Salvar nova senha',
    _ => '',
  };

  VoidCallback? get _onPrimaryPressed => switch (_step) {
    _ForgotPasswordStep.email => _submitEmail,
    _ForgotPasswordStep.newPassword => _submitNewPassword,
    _ => null,
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
          'Senha redefinida com sucesso!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Use sua nova senha para entrar na Pokédex.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        AppButton(label: 'Voltar ao login', onPressed: onDone),
      ],
    );
  }
}

class _EmailSentBody extends StatelessWidget {
  const _EmailSentBody({required this.email, required this.onDone});

  final String email;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Verifique seu e-mail',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enviamos um link para redefinir sua senha em $email.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        AppButton(label: 'Voltar ao login', onPressed: onDone),
      ],
    );
  }
}
