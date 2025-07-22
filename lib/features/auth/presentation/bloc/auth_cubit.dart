import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignOutUseCase _signOutUseCase;
  final Logger _logger = Logger();

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthCubit({
    required AuthRepository authRepository,
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _authRepository = authRepository,
        _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _signOutUseCase = signOutUseCase,
        super(AuthInitial()) {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
      onError: (error) {
        _logger.e('Auth state error: $error');
        emit(AuthError('Authentication error occurred'));
      },
    );
  }

  Future<void> getCurrentUser() async {
    emit(AuthLoading());
    
    final result = await _getCurrentUserUseCase();
    
    result.fold(
      (failure) {
        _logger.e('Get current user failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(SignInLoading());
    
    final result = await _signInUseCase(
      SignInParams(email: email, password: password),
    );
    
    result.fold(
      (failure) {
        _logger.e('Sign in failed: ${failure.message}');
        emit(SignInError(failure.message));
      },
      (user) {
        _logger.i('Sign in successful for user: ${user.email}');
        emit(SignInSuccess(user));
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(SignUpLoading());
    
    final result = await _signUpUseCase(
      SignUpParams(email: email, password: password, name: name),
    );
    
    result.fold(
      (failure) {
        _logger.e('Sign up failed: ${failure.message}');
        emit(SignUpError(failure.message));
      },
      (user) {
        _logger.i('Sign up successful for user: ${user.email}');
        emit(SignUpSuccess(user));
      },
    );
  }

  Future<void> signInWithGoogle() async {
    emit(SignInLoading());
    
    final result = await _authRepository.signInWithGoogle();
    
    result.fold(
      (failure) {
        _logger.e('Google sign in failed: ${failure.message}');
        emit(SignInError(failure.message));
      },
      (user) {
        _logger.i('Google sign in successful for user: ${user.email}');
        emit(SignInSuccess(user));
      },
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    
    final result = await _signOutUseCase();
    
    result.fold(
      (failure) {
        _logger.e('Sign out failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (_) {
        _logger.i('Sign out successful');
        emit(AuthUnauthenticated());
      },
    );
  }

  bool get isAuthenticated => _authRepository.isAuthenticated;

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
