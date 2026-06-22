import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';

enum ChangePasswordStep { current, newPassword, confirm, success }

class ChangePasswordFlowState {
  const ChangePasswordFlowState({
    this.step = ChangePasswordStep.current,
    this.loading = false,
    this.error,
    this.verifiedCurrentPassword = '',
  });

  final ChangePasswordStep step;
  final bool loading;
  final String? error;
  final String verifiedCurrentPassword;

  ChangePasswordFlowState copyWith({
    ChangePasswordStep? step,
    bool? loading,
    String? error,
    String? verifiedCurrentPassword,
    bool clearError = false,
  }) {
    return ChangePasswordFlowState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      verifiedCurrentPassword:
          verifiedCurrentPassword ?? this.verifiedCurrentPassword,
    );
  }
}

class ChangePasswordFlowNotifier extends Notifier<ChangePasswordFlowState> {
  @override
  ChangePasswordFlowState build() => const ChangePasswordFlowState();

  Future<void> submitCurrent(String currentPassword) async {
    if (currentPassword.isEmpty) {
      state = state.copyWith(error: 'Informe sua senha atual');
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      final valid = await ref
          .read(authProvider.notifier)
          .verifyCurrentPassword(currentPassword);
      if (!valid) {
        state = state.copyWith(loading: false, error: 'Senha atual incorreta');
        return;
      }
      state = state.copyWith(
        loading: false,
        step: ChangePasswordStep.newPassword,
        verifiedCurrentPassword: currentPassword,
      );
    } finally {
      if (state.loading) {
        state = state.copyWith(loading: false);
      }
    }
  }

  void submitNew(String newPassword) {
    final passwordError = PasswordPolicy.validate(newPassword);
    if (passwordError != null) {
      state = state.copyWith(error: passwordError);
      return;
    }
    state = state.copyWith(clearError: true, step: ChangePasswordStep.confirm);
  }

  Future<void> submitConfirm({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (confirmPassword != newPassword) {
      state = state.copyWith(error: 'As senhas não coincidem');
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      await ref.read(authProvider.notifier).changePassword(
            currentPassword: state.verifiedCurrentPassword,
            newPassword: newPassword,
          );
      state = state.copyWith(loading: false, step: ChangePasswordStep.success);
    } on Object catch (e) {
      state = state.copyWith(loading: false, error: formatAuthException(e));
    }
  }

  void goBackStep() {
    state = state.copyWith(
      clearError: true,
      step: switch (state.step) {
        ChangePasswordStep.newPassword => ChangePasswordStep.current,
        ChangePasswordStep.confirm => ChangePasswordStep.newPassword,
        _ => state.step,
      },
    );
  }
}

final NotifierProvider<ChangePasswordFlowNotifier, ChangePasswordFlowState>
    changePasswordFlowProvider =
    NotifierProvider.autoDispose<ChangePasswordFlowNotifier,
        ChangePasswordFlowState>(
  ChangePasswordFlowNotifier.new,
);
