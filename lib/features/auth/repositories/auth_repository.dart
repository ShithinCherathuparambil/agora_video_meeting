import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null;
    });
  }

  /// Get current user
  UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null;
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      final user = UserModel.fromFirebaseUser(credential.user!);
      await _updateUserInFirestore(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Create account with email and password
  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Account creation failed');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      final user = UserModel.fromFirebaseUser(_firebaseAuth.currentUser!);
      await _createUserInFirestore(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw Exception('Google sign in failed');
      }

      final user = UserModel.fromFirebaseUser(userCredential.user!);
      await _updateUserInFirestore(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send verification email: ${e.toString()}');
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserInFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      // Log error but don't throw - auth should still work
      print('Failed to create user in Firestore: $e');
    }
  }

  /// Update user document in Firestore
  Future<void> _updateUserInFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      // Log error but don't throw - auth should still work
      print('Failed to update user in Firestore: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
