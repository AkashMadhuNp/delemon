import 'package:delemon/core/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:delemon/data/models/user_model.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> handleSignUp({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required String? selectedRole,
    required Function(bool) setLoading,
    required Function() clearForm,
  }) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedRole == null) {
      _showSnackBar(context, "Please select your role", isError: true);
      return;
    }

    setLoading(true);

    try {
      final result = await _authService.signUp(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole,
      );

      if (!context.mounted) return;

      if (result.isSuccess) {
        clearForm();
        _showSnackBar(context, result.message, isError: false);
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        _showSnackBar(context, result.message, isError: true);
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleLogin({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
    required Function(UserModel) onLoginSuccess,
  }) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);

    try {
      final result = await _authService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!context.mounted) return;

      if (result.isSuccess && result.user != null) {
        _showSnackBar(context, result.message, isError: false);
        onLoginSuccess(result.user!);
      } else {
        _showSnackBar(context, result.message, isError: true);
      }
    } finally {
      setLoading(false);
    }
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}