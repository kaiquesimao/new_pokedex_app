import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class RegisterEmailPage extends ConsumerStatefulWidget {
  const RegisterEmailPage({super.key});

  @override
  ConsumerState<RegisterEmailPage> createState() => _RegisterEmailPageState();
}

class _RegisterEmailPageState extends ConsumerState<RegisterEmailPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _goBackStep() async {
    await ref.read(registerFlowProvider.notifier).goBackStep();
  }

  void _submitEmail() {
    ref
        .read(registerFlowProvider.notifier)
        .submitEmail(_emailController.text);
  }

  Future<void> _submitPassword() async {
    await ref
        .read(registerFlowProvider.notifier)
        .submitPassword(_passwordController.text);
  }

  Future<void> _submitName() async {
    await ref
        .read(registerFlowProvider.notifier)
        .submitName(_nameController.text);
    if (!mounted) return;
    final flow = ref.read(registerFlowProvider);
    if (flow.error == null && !flow.loading) {
      await context.push('/register/verify-email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(registerFlowProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (flow.step == RegisterStep.email) {
              context.pop();
            } else {
              unawaited(_goBackStep());
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
                  _StepIndicator(current: _stepIndex(flow.step), total: 3),
                  const SizedBox(height: 32),
                  Text(
                    _headline(flow.step),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitle(flow.step),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  switch (flow.step) {
                    RegisterStep.email => AppTextField(
                      label: 'E-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText: flow.error,
                    ),
                    RegisterStep.password => AppPasswordField(
                      label: 'Senha',
                      controller: _passwordController,
                      errorText: flow.error,
                    ),
                    RegisterStep.name => AppTextField(
                      label: 'Nome',
                      controller: _nameController,
                      errorText: flow.error,
                    ),
                  },
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Continuar',
                    isLoading: flow.loading,
                    onPressed: flow.loading ? null : _onPrimaryPressed(flow.step),
                  ),
                ],
              ),
            ),
          ),
          if (flow.loading) AuthLoadingOverlay(message: _loadingMessage(flow.step)),
        ],
      ),
    );
  }

  int _stepIndex(RegisterStep step) => switch (step) {
    RegisterStep.email => 1,
    RegisterStep.password => 2,
    RegisterStep.name => 3,
  };

  String _headline(RegisterStep step) => switch (step) {
    RegisterStep.email => 'Qual é o seu e-mail?',
    RegisterStep.password => 'Crie uma senha',
    RegisterStep.name => 'Como podemos te chamar?',
  };

  String _subtitle(RegisterStep step) => switch (step) {
    RegisterStep.email => 'Usaremos este e-mail para acessar sua conta.',
    RegisterStep.password => PasswordPolicy.requirementsHint,
    RegisterStep.name => 'Este nome aparecerá no seu perfil de treinador.',
  };

  VoidCallback _onPrimaryPressed(RegisterStep step) => switch (step) {
    RegisterStep.email => _submitEmail,
    RegisterStep.password => _submitPassword,
    RegisterStep.name => _submitName,
  };

  String _loadingMessage(RegisterStep step) => switch (step) {
    RegisterStep.password => 'Criando conta...',
    RegisterStep.name => 'Finalizando cadastro...',
    RegisterStep.email => 'Aguarde...',
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
