import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthPasswordResetRequested(email: _emailController.text.trim()),
          );
    }
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
          } else if (state is AuthPasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password reset email sent to ${state.email}'),
                backgroundColor: AppTheme.green,
              ),
            );
            context.pop();
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
                  
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.lightYellow,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 40,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Forgot Password?',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.darkGray,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.mediumGray,
                                height: 1.5,
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
                  
                  const SizedBox(height: 32),
                  
                  // Send Reset Email Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Send Reset Email',
                        onPressed: _sendResetEmail,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Back to Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Sign In',
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
