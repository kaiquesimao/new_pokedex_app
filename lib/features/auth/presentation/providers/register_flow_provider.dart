import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

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
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(error: l10n.authInvalidEmail);
      return;
    }
    state = state.copyWith(
      email: email,
      step: RegisterStep.password,
      clearError: true,
    );
  }

  Future<void> submitPassword(String password) async {
    final passwordError = PasswordPolicy.validateWithL10n(
      lookupAppLocalizations(ref.read(appLocaleProvider).materialLocale),
      password,
    );
    if (passwordError != null) {
      state = state.copyWith(error: passwordError);
      return;
    }

    state = state.copyWith(
      password: password,
      step: RegisterStep.name,
      clearError: true,
    );
  }

  Future<void> submitName(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(error: l10n.authEnterYourName);
      return;
    }

    state = state.copyWith(
      name: name,
      loading: true,
      clearError: true,
    );

    try {
      if (ref.read(authProvider.notifier).usesFirebase) {
        await ref
            .read(authProvider.notifier)
            .signUp(
              email: state.email,
              password: state.password,
              name: name,
            );
      }
      state = state.copyWith(loading: false);
    } on Object catch (e) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(
        loading: false,
        error: formatAuthException(l10n, e),
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
