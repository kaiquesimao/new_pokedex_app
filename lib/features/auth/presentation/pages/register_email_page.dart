import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

enum _RegisterStep { email, password, name }

class RegisterEmailPage extends ConsumerStatefulWidget {
  const RegisterEmailPage({super.key});

  @override
  ConsumerState<RegisterEmailPage> createState() => _RegisterEmailPageState();
}

class _RegisterEmailPageState extends ConsumerState<RegisterEmailPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  _RegisterStep _step = _RegisterStep.email;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _goBackStep() async {
    if (_step == _RegisterStep.password &&
        ref.read(authProvider).needsEmailVerification) {
      await ref.read(authProvider.notifier).signOut();
    }

    if (!mounted) return;

    setState(() {
      _error = null;
      _step = switch (_step) {
        _RegisterStep.password => _RegisterStep.email,
        _RegisterStep.name => _RegisterStep.password,
        _ => _step,
      };
    });
  }

  void _submitEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Informe um e-mail válido');
      return;
    }
    ref.read(registerFlowProvider.notifier).setEmail(email);
    setState(() {
      _error = null;
      _step = _RegisterStep.password;
    });
  }

  Future<void> _submitPassword() async {
    final password = _passwordController.text;
    final passwordError = PasswordPolicy.validate(password);
    if (passwordError != null) {
      setState(() => _error = passwordError);
      return;
    }

    final draft = ref.read(registerFlowProvider);
    ref.read(registerFlowProvider.notifier).setPassword(password);

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (ref.read(authProvider.notifier).usesFirebase) {
        await ref
            .read(authProvider.notifier)
            .createPendingAccount(email: draft.email, password: password);
      }
      if (mounted) {
        setState(() {
          _error = null;
          _step = _RegisterStep.name;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = formatAuthException(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Informe seu nome');
      return;
    }

    ref.read(registerFlowProvider.notifier).setName(name);
    final draft = ref.read(registerFlowProvider);

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (ref.read(authProvider.notifier).usesFirebase) {
        await ref
            .read(authProvider.notifier)
            .completePendingRegistration(name: draft.name);
      }
      if (mounted) context.push('/register/verify-email');
    } catch (e) {
      if (mounted) setState(() => _error = formatAuthException(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == _RegisterStep.email) {
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
                  switch (_step) {
                    _RegisterStep.email => AppTextField(
                      label: 'E-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _error,
                    ),
                    _RegisterStep.password => AppPasswordField(
                      label: 'Senha',
                      controller: _passwordController,
                      errorText: _error,
                    ),
                    _RegisterStep.name => AppTextField(
                      label: 'Nome',
                      controller: _nameController,
                      errorText: _error,
                    ),
                  },
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Continuar',
                    isLoading: _loading,
                    onPressed: _loading ? null : _onPrimaryPressed,
                  ),
                ],
              ),
            ),
          ),
          if (_loading) AuthLoadingOverlay(message: _loadingMessage),
        ],
      ),
    );
  }

  int get _stepIndex => switch (_step) {
    _RegisterStep.email => 1,
    _RegisterStep.password => 2,
    _RegisterStep.name => 3,
  };

  String get _headline => switch (_step) {
    _RegisterStep.email => 'Qual é o seu e-mail?',
    _RegisterStep.password => 'Crie uma senha',
    _RegisterStep.name => 'Como podemos te chamar?',
  };

  String get _subtitle => switch (_step) {
    _RegisterStep.email => 'Usaremos este e-mail para acessar sua conta.',
    _RegisterStep.password => PasswordPolicy.requirementsHint,
    _RegisterStep.name => 'Este nome aparecerá no seu perfil de treinador.',
  };

  VoidCallback get _onPrimaryPressed => switch (_step) {
    _RegisterStep.email => _submitEmail,
    _RegisterStep.password => _submitPassword,
    _RegisterStep.name => _submitName,
  };

  String get _loadingMessage => switch (_step) {
    _RegisterStep.password => 'Criando conta...',
    _RegisterStep.name => 'Finalizando cadastro...',
    _ => 'Aguarde...',
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
