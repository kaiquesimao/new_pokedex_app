import 'package:firebase_auth/firebase_auth.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';

enum FirebaseAuthErrorContext { emailSignIn, emailSignUp, oauth, general }

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

String firebaseAuthErrorMessage(
  Object error, {
  FirebaseAuthErrorContext context = FirebaseAuthErrorContext.general,
}) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'E-mail inválido',
      'user-disabled' => 'Conta desativada',
      'user-not-found' => switch (context) {
        FirebaseAuthErrorContext.emailSignIn =>
          'Não encontramos uma conta com este e-mail. Crie uma conta para continuar.',
        _ => 'Usuário não encontrado',
      },
      'wrong-password' =>
        'Senha incorreta. Tente novamente ou use "Esqueci minha senha".',
      'email-already-in-use' => switch (context) {
        FirebaseAuthErrorContext.emailSignUp => emailAlreadyInUseMessage(),
        _ => 'Este e-mail já está em uso',
      },
      'weak-password' => PasswordPolicy.requirementsHint,
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde',
      'network-request-failed' => 'Sem conexão. Verifique sua internet',
      'requires-recent-login' => 'Faça login novamente para continuar',
      'invalid-credential' => switch (context) {
        FirebaseAuthErrorContext.emailSignIn =>
          'E-mail ou senha incorretos. Se você ainda não tem conta, toque em "Criar conta".',
        FirebaseAuthErrorContext.oauth =>
          'Falha ao entrar. Se o problema continuar, verifique SHA-1/SHA-256 no Firebase e baixe o google-services.json novamente.',
        _ => 'Credenciais inválidas. Tente novamente.',
      },
      'account-exists-with-different-credential' =>
        'Este e-mail já está cadastrado com outro método de login. Use Google, Apple ou o método original.',
      'operation-not-allowed' =>
        'Este método de login não está habilitado no Firebase',
      _ => error.message ?? 'Erro de autenticação',
    };
  }
  return error.toString();
}

String emailAlreadyInUseMessage({List<String> signInMethods = const []}) {
  if (signInMethods.contains('google.com')) {
    return 'Este e-mail já está em uso com Google. '
        'Use "Já tenho uma conta" e entre com Google.';
  }
  if (signInMethods.contains('apple.com')) {
    return 'Este e-mail já está em uso com Apple. '
        'Use "Já tenho uma conta" e entre com Apple.';
  }
  if (signInMethods.contains('password')) {
    return 'Este e-mail já está em uso. Use "Já tenho uma conta" para entrar.';
  }
  return 'Este e-mail já está em uso. '
      'Tente entrar com Google ou use "Já tenho uma conta".';
}

String formatAuthException(Object error) {
  if (error is AuthException) return error.message;
  var message = error.toString();
  while (message.startsWith('Exception: ')) {
    message = message.substring('Exception: '.length);
  }
  return message;
}
