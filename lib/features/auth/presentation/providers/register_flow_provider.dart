import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';

enum RegisterStep { email, password, name }

class RegisterFlowState {
  const RegisterFlowState({
    this.step = RegisterStep.email,
    this.email = '',
    this.password = '',
    this.name = '',
    this.loading = false,
    this.error,
  });

  final RegisterStep step;
  final String email;
  final String password;
  final String name;
  final bool loading;
  final String? error;

  bool get isComplete =>
      email.isNotEmpty && password.isNotEmpty && name.isNotEmpty;

  RegisterFlowState copyWith({
    RegisterStep? step,
    String? email,
    String? password,
    String? name,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return RegisterFlowState(
      step: step ?? this.step,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RegisterFlowNotifier extends Notifier<RegisterFlowState> {
  @override
  RegisterFlowState build() => const RegisterFlowState();

  void submitEmail(String rawEmail) {
    final email = rawEmail.trim();
    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(error: 'Informe um e-mail válido');
      return;
    }
    state = state.copyWith(
      email: email,
      step: RegisterStep.password,
      clearError: true,
    );
  }

  Future<void> submitPassword(String password) async {
    final passwordError = PasswordPolicy.validate(password);
    if (passwordError != null) {
      state = state.copyWith(error: passwordError);
      return;
    }

    state = state.copyWith(
      password: password,
      loading: true,
      clearError: true,
    );

    try {
      if (ref.read(authProvider.notifier).usesFirebase) {
        await ref.read(authProvider.notifier).createPendingAccount(
              email: state.email,
              password: password,
            );
      }
      state = state.copyWith(
        step: RegisterStep.name,
        loading: false,
      );
    } on Object catch (e) {
      state = state.copyWith(
        loading: false,
        error: formatAuthException(e),
      );
    }
  }

  Future<void> submitName(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      state = state.copyWith(error: 'Informe seu nome');
      return;
    }

    state = state.copyWith(
      name: name,
      loading: true,
      clearError: true,
    );

    try {
      if (ref.read(authProvider.notifier).usesFirebase) {
        await ref.read(authProvider.notifier).completePendingRegistration(
              name: name,
            );
      }
      state = state.copyWith(loading: false);
    } on Object catch (e) {
      state = state.copyWith(
        loading: false,
        error: formatAuthException(e),
      );
    }
  }

  Future<void> goBackStep() async {
    if (state.step == RegisterStep.password &&
        ref.read(authProvider).needsEmailVerification) {
      await ref.read(authProvider.notifier).signOut();
    }

    final previousStep = switch (state.step) {
      RegisterStep.password => RegisterStep.email,
      RegisterStep.name => RegisterStep.password,
      RegisterStep.email => RegisterStep.email,
    };

    state = state.copyWith(
      step: previousStep,
      clearError: true,
    );
  }

  void reset() {
    state = const RegisterFlowState();
  }
}

final registerFlowProvider =
    NotifierProvider<RegisterFlowNotifier, RegisterFlowState>(
      RegisterFlowNotifier.new,
    );
