import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<UserModel?> _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    
    // Listen to authentication state changes
    _userSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );

    on<AuthStarted>(_onAuthStarted);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthEmailVerificationRequested>(_onAuthEmailVerificationRequested);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email: event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthEmailVerificationRequested(
    AuthEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendEmailVerification();
      emit(const AuthEmailVerificationSent());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
