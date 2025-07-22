import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        createdAt,
        lastLoginAt,
        isEmailVerified,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
