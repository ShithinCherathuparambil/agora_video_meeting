import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
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
                  const SizedBox(height: 40),
                  
                  // App Logo and Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryYellow,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.video_call,
                            size: 50,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.darkGray,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back! Sign in to continue',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.mediumGray),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    validator: _validatePassword,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.mediumGray),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryYellow,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign In Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Sign In',
                        onPressed: _signIn,
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
