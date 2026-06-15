import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterDraft {
  const RegisterDraft({this.email = '', this.password = '', this.name = ''});

  final String email;
  final String password;
  final String name;

  bool get isComplete =>
      email.isNotEmpty && password.isNotEmpty && name.isNotEmpty;

  RegisterDraft copyWith({String? email, String? password, String? name}) {
    return RegisterDraft(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
    );
  }
}

class RegisterFlowNotifier extends Notifier<RegisterDraft> {
  @override
  RegisterDraft build() => const RegisterDraft();

  void setEmail(String email) {
    state = state.copyWith(email: email.trim());
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void setName(String name) {
    state = state.copyWith(name: name.trim());
  }

  void reset() {
    state = const RegisterDraft();
  }
}

final registerFlowProvider =
    NotifierProvider<RegisterFlowNotifier, RegisterDraft>(
      RegisterFlowNotifier.new,
    );
