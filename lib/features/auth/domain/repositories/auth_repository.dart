import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Get current authenticated user
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  
  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  
  /// Sign out
  Future<Either<Failure, void>> signOut();
  
  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });
  
  /// Update user profile
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? name,
    String? photoUrl,
  });
  
  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();
  
  /// Check if user is authenticated
  bool get isAuthenticated;
  
  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}
