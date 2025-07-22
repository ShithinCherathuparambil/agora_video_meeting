import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl({required FirebaseAuthDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmailAndPassword(email, password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Sign in failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _dataSource.signUpWithEmailAndPassword(email, password, name);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Sign up failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Google sign in failed'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Sign out failed'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _dataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to send password reset email'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      final user = await _dataSource.updateUserProfile(name: name, photoUrl: photoUrl);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to update profile'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _dataSource.deleteAccount();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to delete account'));
    }
  }

  @override
  bool get isAuthenticated => _dataSource.isAuthenticated;

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;
}
