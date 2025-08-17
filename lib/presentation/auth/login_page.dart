import 'package:delemon/presentation/admin/admin_dashboard.dart';
import 'package:delemon/presentation/auth/controllers/auth_controller.dart';
import 'package:delemon/presentation/auth/signup_page.dart';
import 'package:delemon/presentation/staff/staff_dashboard.dart';
import 'package:delemon/presentation/widgets/custom_textform.dart';
import 'package:delemon/presentation/widgets/custom_button.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final AuthController _authController = AuthController();

  Future<void> _handleLogin() async {
    await _authController.handleLogin(
      context: context,
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      setLoading: (loading) => setState(() => _isLoading = loading),
      onLoginSuccess: _navigateBasedOnRole,
    );
  }

  void _navigateBasedOnRole(UserModel user) {
    Widget destination;
    
    if (user.role == UserRoleAdapter.admin) {
      destination = AdminDashboard();
    } else {
      destination = StaffDashboard();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  void _handleSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot password functionality - Coming soon!')),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Lottie.asset("assets/zpunet icon.json", height: 200, width: 200),
                      const SizedBox(height: 48),

                      // Email Field
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

                      // Password Field
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
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Login Button
                      CustomButton(
                        label: "L O G I N",
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.2))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.2))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('Google Sign In - Coming Soon!')),
                              ),
                              icon: const Icon(Icons.g_mobiledata, size: 20),
                              label: const Text('Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(

                                const SnackBar(
                                    duration: Duration(seconds: 1),

                                  content: Text('Apple Sign In - Coming Soon!')),
                              ),
                              icon: const Icon(Icons.apple, size: 20),
                              label: const Text('Apple'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: _handleSignUp,
                            child: Text(
                              'Sign Up',
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}