import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        ),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkGray),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            context.go('/home');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppTheme.darkGray,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join GooTeam Stream and start connecting',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.mediumGray),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name Field
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    validator: _validateName,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppTheme.mediumGray,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.mediumGray,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    validator: _validatePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.mediumGray,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Confirm Password Field
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    validator: _validateConfirmPassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.mediumGray,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign Up Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Create Account',
                        onPressed: _signUp,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppTheme.lightGray)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.mediumGray,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppTheme.lightGray)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google Sign In Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Continue with Google',
                        onPressed: _signInWithGoogle,
                        isLoading: state is AuthLoading,
                        isOutlined: true,
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.primaryYellow,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
