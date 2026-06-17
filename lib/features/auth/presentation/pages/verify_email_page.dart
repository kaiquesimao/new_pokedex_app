import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/otp_code_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  String? _error;
  bool _loading = false;
  var _resent = false;

  bool get _usesFirebase => ref.read(authProvider.notifier).usesFirebase;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final draft = ref.read(registerFlowProvider);
      if (!draft.isComplete) {
        if (mounted) context.go('/register/email');
        return;
      }

      if (!_usesFirebase) {
        try {
          await ref.read(authProvider.notifier).sendOtp(email: draft.email);
        } on Object catch (e) {
          if (mounted) setState(() => _error = formatAuthException(e));
        }
      }
    });
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final draft = ref.read(registerFlowProvider);
      final verified = await ref
          .read(authProvider.notifier)
          .verifyOtp(email: draft.email, code: '');

      if (!verified) {
        setState(() {
          _error = _usesFirebase
              ? 'E-mail ainda não verificado. Abra o link enviado e tente novamente.'
              : 'Código inválido. Tente novamente.';
        });
        return;
      }

      await ref
          .read(authProvider.notifier)
          .signUp(
            email: draft.email,
            password: draft.password,
            name: draft.name,
          );

      ref.read(registerFlowProvider.notifier).reset();
      if (mounted) context.go('/register/success');
    } on Object catch (e) {
      if (mounted) setState(() => _error = formatAuthException(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final draft = ref.read(registerFlowProvider);
    try {
      await ref.read(authProvider.notifier).sendOtp(email: draft.email);
      if (mounted) {
        setState(() => _resent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _usesFirebase
                  ? 'E-mail de verificação reenviado'
                  : 'Código reenviado (mock)',
            ),
          ),
        );
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = formatAuthException(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(registerFlowProvider);
    final theme = Theme.of(context);
    final usesFirebase = ref.watch(firebaseBootstrapProvider).isAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar e-mail')),
      body: Stack(
        children: [
          SafePageBody.belowAppBar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Confirme seu e-mail',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    usesFirebase
                        ? 'Enviamos um link de verificação para ${draft.email}. Abra o e-mail, confirme o link e volte aqui para continuar.'
                        : 'Enviamos um código de 6 dígitos para ${draft.email}.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (usesFirebase) ...[
                    AppButton(
                      label: 'Já confirmei no e-mail',
                      isLoading: _loading,
                      onPressed: _completeRegistration,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _resend,
                        child: const Text('Reenviar e-mail'),
                      ),
                    ),
                  ] else
                    OtpCodeField(
                      errorText: _error,
                      onCompleted: (_) => _completeRegistration(),
                      onResend: _resend,
                    ),
                  if (_error != null && usesFirebase) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_resent) ...[
                    const SizedBox(height: 8),
                    Text(
                      usesFirebase
                          ? 'Um novo e-mail foi enviado.'
                          : 'Um novo código foi enviado.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_loading && !usesFirebase)
            const AuthLoadingOverlay(message: 'Criando conta...'),
          if (_loading && usesFirebase)
            const AuthLoadingOverlay(message: 'Verificando...'),
        ],
      ),
    );
  }
}
