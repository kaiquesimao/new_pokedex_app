import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
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

      try {
        if (_usesFirebase) {
          await ref
              .read(authProvider.notifier)
              .createPendingAccount(
                email: draft.email,
                password: draft.password,
                name: draft.name,
              );
        } else {
          await ref.read(authProvider.notifier).sendOtp(email: draft.email);
        }
      } catch (e) {
        if (mounted) setState(() => _error = e.toString());
      }
    });
  }

  Future<void> _verify(String code) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final draft = ref.read(registerFlowProvider);
      final valid = await ref
          .read(authProvider.notifier)
          .verifyOtp(email: draft.email, code: code);

      if (!valid) {
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
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final draft = ref.read(registerFlowProvider);
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
                        ? 'Enviamos um link de verificação para ${draft.email}. Após confirmar, digite qualquer código de 6 dígitos para continuar.'
                        : 'Enviamos um código de 6 dígitos para ${draft.email}.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  OtpCodeField(
                    errorText: _error,
                    onCompleted: _verify,
                    onResend: _resend,
                  ),
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
          if (_loading) const AuthLoadingOverlay(message: 'Criando conta...'),
        ],
      ),
    );
  }
}
