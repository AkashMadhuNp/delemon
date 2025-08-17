import 'package:delemon/presentation/auth/controllers/auth_controller.dart';
import 'package:delemon/presentation/widgets/custom_textform.dart';
import 'package:delemon/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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


  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _selectedRole;

  
  final List<String> _roles = ['Staff', 'Admin'];
  final AuthController _authController = AuthController();

  
  Future<void> _handleSignup() async {
    await _authController.handleSignUp(
      context: context,
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      selectedRole: _selectedRole,
      setLoading: (loading) => setState(() => _isLoading = loading),
      clearForm: _clearForm,
    );
  }

  
  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _selectedRole = null);
  }

  
  void _handleLogin() {
    Navigator.of(context).pop();
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
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter your email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      
                      _buildRoleDropdown(theme),
                      const SizedBox(height: 20),

                      
                      CustomTextField(
                        controller: _passwordController,
                        label: "Password",
                        hint: "Enter your password",
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
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
                        obscureText: _obscureConfirmPassword,
                        onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      
                      CustomButton(
                        label: "S I G N   U P",
                        isLoading: _isLoading,
                        onPressed: _handleSignup,
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
                            onPressed: _handleLogin,
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
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildRoleDropdown(ThemeData theme) {
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
            value: _selectedRole,
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
            onChanged: (String? newValue) => setState(() => _selectedRole = newValue),
            validator: (value) => value == null ? 'Please select your role' : null,
          ),
        ),
      ],
    );
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