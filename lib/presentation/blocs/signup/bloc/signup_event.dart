import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpSubmitted extends SignUpEvent {
  final String name;
  final String email;
  final String password;
  final String? role;

  const SignUpSubmitted({
    required this.name,
    required this.email,
    required this.password,
    this.role,
  });

  @override
  List<Object?> get props => [name, email, password, role];
}

class SignUpRoleChanged extends SignUpEvent {
  final String? role;

  const SignUpRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}

class SignUpFormCleared extends SignUpEvent {}

class SignUpPasswordVisibilityToggled extends SignUpEvent {
  final bool isPassword;

  const SignUpPasswordVisibilityToggled({required this.isPassword});

  @override
  List<Object?> get props => [isPassword];
}
