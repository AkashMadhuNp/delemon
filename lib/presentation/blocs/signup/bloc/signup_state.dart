import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {
  final String? selectedRole;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  const SignUpInitial({
    this.selectedRole,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  @override
  List<Object?> get props => [selectedRole, obscurePassword, obscureConfirmPassword];

  SignUpInitial copyWith({
    String? selectedRole,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
  }) {
    return SignUpInitial(
      selectedRole: selectedRole,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }
}

class SignUpLoading extends SignUpState {
  final String? selectedRole;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  const SignUpLoading({
    this.selectedRole,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  @override
  List<Object?> get props => [selectedRole, obscurePassword, obscureConfirmPassword];
}

class SignUpSuccess extends SignUpState {}

class SignUpFailure extends SignUpState {
  final String error;
  final String? selectedRole;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  const SignUpFailure({
    required this.error,
    this.selectedRole,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  @override
  List<Object?> get props => [error, selectedRole, obscurePassword, obscureConfirmPassword];
}
