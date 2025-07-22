import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gooteam_stream/features/auth/presentation/bloc/register_cubit.dart';
import 'package:gooteam_stream/features/auth/presentation/widgets/custom_button.dart';
import 'package:gooteam_stream/features/auth/presentation/widgets/custom_text_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocProvider(
        create: (_) => RegisterCubit(context.read()),
        child: const RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Authentication Failure')),
            );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _EmailInput(),
            const SizedBox(height: 20),
            _PasswordInput(),
            const SizedBox(height: 20),
            _RegisterButton(),
            const SizedBox(height: 20),
            _LoginButton(),
          ],
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return CustomTextField(
          label: 'Email',
          onChanged: (email) => context.read<RegisterCubit>().emailChanged(email),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return CustomTextField(
          label: 'Password',
          obscureText: true,
          onChanged: (password) => context.read<RegisterCubit>().passwordChanged(password),
        );
      },
    );
  }
}

class _RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status == RegisterStatus.submitting
            ? const CircularProgressIndicator()
            : CustomButton(
                text: 'Register',
                onPressed: () => context.read<RegisterCubit>().signUpWithCredentials(),
              );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Login',
      onPressed: () => context.go('/login'),
      isOutlined: true,
    );
  }
}
