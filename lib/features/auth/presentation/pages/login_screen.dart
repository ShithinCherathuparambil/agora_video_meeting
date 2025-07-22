import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignInSuccess || state is AuthAuthenticated) {
          AppNavigation.goToHome(context);
        } else if (state is SignInError) {
          AppUtils.showSnackBar(context, state.message, isError: true);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is SignInLoading,
            message: 'Signing in...',
            child: AppScaffold(
              backgroundColor: AppTheme.offWhite,
              showBackButton: false,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      
                      // App Logo
                      Center(
                        child: Container(
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
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Welcome Text
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Sign in to continue to VideoMeet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!AppUtils.isValidEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSubmitted: (_) {
                          _passwordFocusNode.requestFocus();
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSubmitted: (_) {
                          _signIn();
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sign In Button
                      CustomButton(
                        text: 'Sign In',
                        onPressed: _signIn,
                        isLoading: state is SignInLoading,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Forgot Password
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppTheme.primaryYellow.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Google Sign In Button
                      CustomButton(
                        text: 'Continue with Google',
                        type: ButtonType.outline,
                        icon: Icons.g_mobiledata,
                        onPressed: () {
                          context.read<AuthCubit>().signInWithGoogle();
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              AppNavigation.goToRegister(context);
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppTheme.primaryYellow.withValues(alpha: 0.8),
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
          );
        },
      ),
    );
  }

  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }
}
