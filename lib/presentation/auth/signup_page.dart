// Enhanced SignUp Screen with better navigation handling
import 'package:delemon/presentation/blocs/signup/bloc/signup_bloc.dart';
import 'package:delemon/presentation/blocs/signup/bloc/signup_event.dart';
import 'package:delemon/presentation/blocs/signup/bloc/signup_state.dart';
import 'package:delemon/presentation/widgets/custom_textform.dart';
import 'package:delemon/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _roles = ['Staff', 'Admin'];
  bool _isNavigating = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignUpBloc>().add(SignUpFormCleared());
    });
  }

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      final currentState = context.read<SignUpBloc>().state;
      final selectedRole = _getSelectedRole(currentState);
      
      if (selectedRole == null) {
        _showSnackBar('Please select your role', isError: true);
        return;
      }

      context.read<SignUpBloc>().add(SignUpSubmitted(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: selectedRole,
      ));
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    context.read<SignUpBloc>().add(SignUpFormCleared());
  }

  void _handleLogin() {
    if (_isNavigating) return; // Prevent multiple navigations
    
    _isNavigating = true;
    context.read<SignUpBloc>().add(SignUpFormCleared());
    context.go('/login');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing snackbars
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: mediaQuery.size.width > 600 ? 400 : double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: BlocConsumer<SignUpBloc, SignUpState>(
                  listener: (context, state) {
                    if (state is SignUpSuccess && !_isNavigating) {
                      _isNavigating = true;
                      _showSnackBar('Account created successfully!');
                      _clearForm();
                      
                      // Navigate after showing success message
                      Future.delayed(const Duration(milliseconds: 2000), () {
                        if (mounted && _isNavigating) {
                          context.go('/login');
                        }
                      });
                    } else if (state is SignUpFailure) {
                      _showSnackBar(state.error, isError: true);
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is SignUpLoading;
                    final selectedRole = _getSelectedRole(state);
                    final obscurePassword = _getObscurePassword(state);
                    final obscureConfirmPassword = _getObscureConfirmPassword(state);

                    return AbsorbPointer(
                      absorbing: _isNavigating, 
                      child: Opacity(
                        opacity: _isNavigating ? 0.7 : 1.0,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Lottie.asset("assets/zpunet icon.json", height: 200, width: 200),
                              const SizedBox(height: 48),

                              CustomTextField(
                                controller: _nameController,
                                label: "Full Name",
                                hint: "Enter your full name",
                                prefixIcon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                                enabled: !isLoading && !_isNavigating,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Please enter your full name';
                                  if (value!.length < 2) return 'Name must be at least 2 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              CustomTextField(
                                controller: _emailController,
                                label: "Email Address",
                                hint: "Enter your email address",
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading && !_isNavigating,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Please enter your email';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              _buildRoleDropdown(theme, selectedRole, isLoading || _isNavigating),
                              const SizedBox(height: 20),

                              CustomTextField(
                                controller: _passwordController,
                                label: "Password",
                                hint: "Enter your password",
                                prefixIcon: Icons.lock_outline,
                                obscureText: obscurePassword,
                                enabled: !isLoading && !_isNavigating,
                                onToggleObscure: () => context.read<SignUpBloc>().add(
                                  const SignUpPasswordVisibilityToggled(isPassword: true),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Please enter your password';
                                  if (value!.length < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              CustomTextField(
                                controller: _confirmPasswordController,
                                label: "Confirm Password",
                                hint: "Confirm your password",
                                prefixIcon: Icons.lock_outline,
                                obscureText: obscureConfirmPassword,
                                enabled: !isLoading && !_isNavigating,
                                onToggleObscure: () => context.read<SignUpBloc>().add(
                                  const SignUpPasswordVisibilityToggled(isPassword: false),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Please confirm your password';
                                  if (value != _passwordController.text) return 'Passwords do not match';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              CustomButton.sync(
                                label: "S I G N   U P",
                                isLoading: isLoading,
                                onPressed: (isLoading || _isNavigating) ? () {} : _handleSignup,
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (isLoading || _isNavigating) ? null : _handleLogin,
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(ThemeData theme, String? selectedRole, bool isDisabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(
              hintText: 'Select your role',
              prefixIcon: Icon(
                Icons.work_outline,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            dropdownColor: theme.colorScheme.surface,
            items: _roles.map((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role, style: theme.textTheme.bodyMedium),
              );
            }).toList(),
            onChanged: isDisabled ? null : (String? newValue) {
              context.read<SignUpBloc>().add(SignUpRoleChanged(newValue));
            },
            validator: (value) => value == null ? 'Please select your role' : null,
          ),
        ),
      ],
    );
  }

  String? _getSelectedRole(SignUpState state) {
    if (state is SignUpInitial) return state.selectedRole;
    if (state is SignUpFailure) return state.selectedRole;
    if (state is SignUpLoading) return state.selectedRole;
    return null;
  }

  bool _getObscurePassword(SignUpState state) {
    if (state is SignUpInitial) return state.obscurePassword;
    if (state is SignUpFailure) return state.obscurePassword;
    if (state is SignUpLoading) return state.obscurePassword;
    return true;
  }

  bool _getObscureConfirmPassword(SignUpState state) {
    if (state is SignUpInitial) return state.obscureConfirmPassword;
    if (state is SignUpFailure) return state.obscureConfirmPassword;
    if (state is SignUpLoading) return state.obscureConfirmPassword;
    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}