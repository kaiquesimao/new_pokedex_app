import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class LoginEmailFormState {
  const LoginEmailFormState({this.loading = false, this.error});

  final bool loading;
  final String? error;

  LoginEmailFormState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return LoginEmailFormState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LoginEmailFormNotifier extends Notifier<LoginEmailFormState> {
  @override
  LoginEmailFormState build() => const LoginEmailFormState();

  Future<void> submit({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await ref
          .read(authProvider.notifier)
          .signIn(
            email: email.trim(),
            password: password,
          );
    } on Object catch (e) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(loading: false, error: formatAuthException(l10n, e));
    } finally {
      if (state.loading) {
        state = state.copyWith(loading: false);
      }
    }
  }
}

final NotifierProvider<LoginEmailFormNotifier, LoginEmailFormState>
loginEmailFormProvider =
    NotifierProvider.autoDispose<LoginEmailFormNotifier, LoginEmailFormState>(
      LoginEmailFormNotifier.new,
    );
