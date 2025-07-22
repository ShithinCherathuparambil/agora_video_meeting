import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Sign In States
class SignInLoading extends AuthState {}

class SignInSuccess extends AuthState {
  final UserEntity user;

  const SignInSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class SignInError extends AuthState {
  final String message;

  const SignInError(this.message);

  @override
  List<Object> get props => [message];
}

// Sign Up States
class SignUpLoading extends AuthState {}

class SignUpSuccess extends AuthState {
  final UserEntity user;

  const SignUpSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class SignUpError extends AuthState {
  final String message;

  const SignUpError(this.message);

  @override
  List<Object> get props => [message];
}
