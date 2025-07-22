import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/services/security_service.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _securityService = SecurityService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignUpSuccess || state is AuthAuthenticated) {
          AppNavigation.goToHome(context);
        } else if (state is SignUpError) {
          AppUtils.showSnackBar(context, state.message, isError: true);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is SignUpLoading,
            message: 'Creating account...',
            child: AppScaffold(
              backgroundColor: AppTheme.offWhite,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      
                      // App Logo
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryYellow,
                            borderRadius: BorderRadius.circular(40),
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
                            size: 40,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Welcome Text
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Join VideoMeet and start connecting',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Name Field
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        prefixIcon: const Icon(Icons.person_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (!_securityService.isValidDisplayName(value)) {
                            return 'Name must be 3-30 characters long';
                          }
                          return null;
                        },
                        onSubmitted: (_) {
                          _emailFocusNode.requestFocus();
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
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
                          if (!_securityService.isValidEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSubmitted: (_) {
                          _passwordFocusNode.requestFocus();
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
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
                          final validation = _securityService.validatePassword(value);
                          if (!validation.isValid) {
                            return validation.errors.first;
                          }
                          return null;
                        },
                        onSubmitted: (_) {
                          _confirmPasswordFocusNode.requestFocus();
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Confirm Password Field
                      CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onSubmitted: (_) {
                          _signUp();
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sign Up Button
                      CustomButton(
                        text: 'Create Account',
                        onPressed: _signUp,
                        isLoading: state is SignUpLoading,
                      ),
                      
                      const SizedBox(height: 24),
                      
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
                      
                      const SizedBox(height: 24),
                      
                      // Google Sign Up Button
                      CustomButton(
                        text: 'Continue with Google',
                        type: ButtonType.outline,
                        icon: Icons.g_mobiledata,
                        onPressed: () {
                          context.read<AuthCubit>().signInWithGoogle();
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              AppNavigation.goToLogin(context);
                            },
                            child: Text(
                              'Sign In',
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

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );
    }
  }
}
