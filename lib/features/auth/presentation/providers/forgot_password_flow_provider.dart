import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';

enum ForgotPasswordStep { email, otp, newPassword, success, emailSent }

class ForgotPasswordFlowState {
  const ForgotPasswordFlowState({
    this.step = ForgotPasswordStep.email,
    this.loading = false,
    this.error,
    this.resent = false,
    this.email = '',
  });

  final ForgotPasswordStep step;
  final bool loading;
  final String? error;
  final bool resent;
  final String email;

  ForgotPasswordFlowState copyWith({
    ForgotPasswordStep? step,
    bool? loading,
    String? error,
    bool? resent,
    String? email,
    bool clearError = false,
  }) {
    return ForgotPasswordFlowState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      resent: resent ?? this.resent,
      email: email ?? this.email,
    );
  }
}

class ForgotPasswordFlowNotifier extends Notifier<ForgotPasswordFlowState> {
  @override
  ForgotPasswordFlowState build() => const ForgotPasswordFlowState();

  Future<void> submitEmail(String rawEmail) async {
    final email = rawEmail.trim();
    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(error: 'Informe um e-mail válido');
      return;
    }

    state = state.copyWith(loading: true, clearError: true, email: email);

    try {
      final usesFirebase = ref.read(firebaseBootstrapProvider).isAvailable;
      if (usesFirebase) {
        await ref
            .read(authProvider.notifier)
            .sendPasswordResetEmail(email: email);
        if (ref.mounted) {
          state = state.copyWith(
            loading: false,
            step: ForgotPasswordStep.emailSent,
          );
        }
      } else {
        await ref.read(authProvider.notifier).sendOtp(email: email);
        if (ref.mounted) {
          state = state.copyWith(
            loading: false,
            step: ForgotPasswordStep.otp,
          );
        }
      }
    } on Object catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          loading: false,
          error: formatAuthException(e),
        );
      }
    }
  }

  Future<void> verifyOtp(String code) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final valid = await ref
          .read(authProvider.notifier)
          .verifyOtp(email: state.email, code: code);

      if (!valid) {
        state = state.copyWith(
          loading: false,
          error: 'Código inválido. Tente novamente.',
        );
        return;
      }

      if (ref.mounted) {
        state = state.copyWith(
          loading: false,
          step: ForgotPasswordStep.newPassword,
        );
      }
    } finally {
      if (ref.mounted && state.loading) {
        state = state.copyWith(loading: false);
      }
    }
  }

  Future<void> resendOtp() async {
    await ref.read(authProvider.notifier).sendOtp(email: state.email);
    state = state.copyWith(resent: true, clearError: true);
  }

  Future<void> submitNewPassword({
    required String password,
    required String confirm,
  }) async {
    final passwordError = PasswordPolicy.validate(password);
    if (passwordError != null) {
      state = state.copyWith(error: passwordError);
      return;
    }

    if (password != confirm) {
      state = state.copyWith(error: 'As senhas não coincidem');
      return;
    }

    state = state.copyWith(loading: true, clearError: true);

    try {
      await ref.read(authProvider.notifier).resetPassword(
            email: state.email,
            newPassword: password,
          );
      if (ref.mounted) {
        state = state.copyWith(
          loading: false,
          step: ForgotPasswordStep.success,
        );
      }
    } on Object catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          loading: false,
          error: formatAuthException(e),
        );
      }
    }
  }

  void goBackStep() {
    state = state.copyWith(
      clearError: true,
      step: switch (state.step) {
        ForgotPasswordStep.otp => ForgotPasswordStep.email,
        ForgotPasswordStep.newPassword => ForgotPasswordStep.otp,
        _ => state.step,
      },
    );
  }
}

final NotifierProvider<ForgotPasswordFlowNotifier, ForgotPasswordFlowState>
    forgotPasswordFlowProvider =
    NotifierProvider.autoDispose<ForgotPasswordFlowNotifier,
        ForgotPasswordFlowState>(
  ForgotPasswordFlowNotifier.new,
);
