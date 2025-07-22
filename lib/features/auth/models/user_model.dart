import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isEmailVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isEmailVerified,
  });

  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
      photoURL: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(map['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoURL,
        createdAt,
        lastLoginAt,
        isEmailVerified,
      ];
}
