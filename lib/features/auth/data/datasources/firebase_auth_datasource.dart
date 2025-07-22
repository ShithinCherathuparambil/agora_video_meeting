import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class FirebaseAuthDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  );
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateUserProfile({String? name, String? photoUrl});
  Future<void> deleteAccount();
  bool get isAuthenticated;
  Stream<UserModel?> get authStateChanges;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  FirebaseAuthDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Get additional user data from Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Create user document if it doesn't exist
        final userModel = UserModel.fromFirebaseUser(
          firebaseUser.uid,
          firebaseUser.email ?? '',
          firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          isEmailVerified: firebaseUser.emailVerified,
        );

        await _createUserDocument(userModel);
        return userModel;
      }
    } catch (e) {
      _logger.e('Error getting current user: $e');
      throw AuthException('Failed to get current user');
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthException('Sign in failed');
      }

      // Update last login time
      await _updateLastLoginTime(firebaseUser.uid);

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        throw AuthException('User data not found');
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      _logger.e('Sign in error: $e');
      throw AuthException('Sign in failed');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthException('Sign up failed');
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user document in Firestore
      final userModel = UserModel.fromFirebaseUser(
        firebaseUser.uid,
        email,
        name,
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
      );

      await _createUserDocument(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      _logger.e('Sign up error: $e');
      throw AuthException('Sign up failed');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        // Web sign-in
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile sign-in
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw AuthException('Google sign in was cancelled');
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException('Google sign in failed');
      }
      // Create or update user document in Firestore
      final userModel = UserModel.fromFirebaseUser(
        firebaseUser.uid,
        firebaseUser.email ?? '',
        firebaseUser.displayName ?? 'User',
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
      );
      await _createUserDocument(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      _logger.e('Google sign in error:  [31m${e.code} - ${e.message} [0m');
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      _logger.e('Google sign in error: $e');
      throw AuthException('Google sign in failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      _logger.e('Sign out error: $e');
      throw AuthException('Sign out failed');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _logger.e('Password reset error: ${e.code} - ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      _logger.e('Password reset error: $e');
      throw AuthException('Failed to send password reset email');
    }
  }

  @override
  Future<UserModel> updateUserProfile({String? name, String? photoUrl}) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('User not authenticated');
      }

      // Update Firebase Auth profile
      if (name != null) {
        await firebaseUser.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await firebaseUser.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .update(updates);
      }

      // Return updated user
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      _logger.e('Update profile error: $e');
      throw AuthException('Failed to update profile');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('User not authenticated');
      }

      // Delete user document from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .delete();

      // Delete Firebase Auth account
      await firebaseUser.delete();
    } catch (e) {
      _logger.e('Delete account error: $e');
      throw AuthException('Failed to delete account');
    }
  }

  @override
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncExpand((firebaseUser) async* {
      if (firebaseUser == null) {
        yield null;
        return;
      }

      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          yield UserModel.fromFirestore(userDoc);
        } else {
          // Create user document if it doesn't exist
          final userModel = UserModel.fromFirebaseUser(
            firebaseUser.uid,
            firebaseUser.email ?? '',
            firebaseUser.displayName ?? 'User',
            photoUrl: firebaseUser.photoURL,
            isEmailVerified: firebaseUser.emailVerified,
          );

          await _createUserDocument(userModel);
          yield userModel;
        }
      } catch (e) {
        _logger.e('Error in auth state changes: $e');
        yield null;
      }
    });
  }

  Future<void> _createUserDocument(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<void> _updateLastLoginTime(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'lastLoginAt': Timestamp.now()});
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      default:
        return 'Authentication failed';
    }
  }
}
