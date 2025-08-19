import 'package:delemon/presentation/blocs/signup/bloc/signup_event.dart';
import 'package:delemon/presentation/blocs/signup/bloc/signup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delemon/core/service/auth_service.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthService _authService;

  SignUpBloc({required AuthService authService})
      : _authService = authService,
        super(const SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<SignUpRoleChanged>(_onRoleChanged);
    on<SignUpFormCleared>(_onFormCleared);
    on<SignUpPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    final currentState = state;
    emit(SignUpLoading(
      selectedRole: event.role,
      obscurePassword: _getObscurePassword(currentState),
      obscureConfirmPassword: _getObscureConfirmPassword(currentState),
    ));

    try {
      final result = await _authService.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role!,
      );
      
      if (result.isSuccess) {
        emit(SignUpSuccess());
      } else {
        emit(SignUpFailure(
          error: result.message,
          selectedRole: event.role,
          obscurePassword: _getObscurePassword(currentState),
          obscureConfirmPassword: _getObscureConfirmPassword(currentState),
        ));
      }
    } catch (error) {
      emit(SignUpFailure(
        error: error.toString(),
        selectedRole: event.role,
        obscurePassword: _getObscurePassword(currentState),
        obscureConfirmPassword: _getObscureConfirmPassword(currentState),
      ));
    }
  }

  void _onRoleChanged(
    SignUpRoleChanged event,
    Emitter<SignUpState> emit,
  ) {
    final currentState = state;
    if (currentState is SignUpInitial) {
      emit(currentState.copyWith(selectedRole: event.role));
    } else if (currentState is SignUpFailure) {
      emit(SignUpFailure(
        error: currentState.error,
        selectedRole: event.role,
        obscurePassword: currentState.obscurePassword,
        obscureConfirmPassword: currentState.obscureConfirmPassword,
      ));
    }
  }

  void _onFormCleared(
    SignUpFormCleared event,
    Emitter<SignUpState> emit,
  ) {
    emit(const SignUpInitial());
  }

  void _onPasswordVisibilityToggled(
    SignUpPasswordVisibilityToggled event,
    Emitter<SignUpState> emit,
  ) {
    final currentState = state;
    
    if (currentState is SignUpInitial) {
      if (event.isPassword) {
        emit(currentState.copyWith(obscurePassword: !currentState.obscurePassword));
      } else {
        emit(currentState.copyWith(obscureConfirmPassword: !currentState.obscureConfirmPassword));
      }
    } else if (currentState is SignUpFailure) {
      final newObscurePassword = event.isPassword ? !currentState.obscurePassword : currentState.obscurePassword;
      final newObscureConfirmPassword = !event.isPassword ? !currentState.obscureConfirmPassword : currentState.obscureConfirmPassword;
      
      emit(SignUpFailure(
        error: currentState.error,
        selectedRole: currentState.selectedRole,
        obscurePassword: newObscurePassword,
        obscureConfirmPassword: newObscureConfirmPassword,
      ));
    }
  }

  bool _getObscurePassword(SignUpState state) {
    if (state is SignUpInitial) return state.obscurePassword;
    if (state is SignUpFailure) return state.obscurePassword;
    return true;
  }

  bool _getObscureConfirmPassword(SignUpState state) {
    if (state is SignUpInitial) return state.obscureConfirmPassword;
    if (state is SignUpFailure) return state.obscureConfirmPassword;
    return true;
  }
}
