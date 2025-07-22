import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ParticipantRole {
  host,
  coHost,
  participant,
  observer,
}

enum ParticipantStatus {
  invited,
  joined,
  left,
  removed,
}

class ParticipantModel extends Equatable {
  final String id;
  final String meetingId;
  final String userId;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final ParticipantRole role;
  final ParticipantStatus status;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final bool isMuted;
  final bool isCameraOn;
  final bool isScreenSharing;
  final bool isHandRaised;
  final Map<String, dynamic> connectionInfo;

  const ParticipantModel({
    required this.id,
    required this.meetingId,
    required this.userId,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.leftAt,
    this.isMuted = false,
    this.isCameraOn = true,
    this.isScreenSharing = false,
    this.isHandRaised = false,
    this.connectionInfo = const {},
  });

  factory ParticipantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParticipantModel(
      id: doc.id,
      meetingId: data['meetingId'] ?? '',
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      role: ParticipantRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => ParticipantRole.participant,
      ),
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ParticipantStatus.invited,
      ),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      leftAt: data['leftAt'] != null
          ? (data['leftAt'] as Timestamp).toDate()
          : null,
      isMuted: data['isMuted'] ?? false,
      isCameraOn: data['isCameraOn'] ?? true,
      isScreenSharing: data['isScreenSharing'] ?? false,
      isHandRaised: data['isHandRaised'] ?? false,
      connectionInfo: Map<String, dynamic>.from(data['connectionInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'meetingId': meetingId,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'status': status.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'leftAt': leftAt != null ? Timestamp.fromDate(leftAt!) : null,
      'isMuted': isMuted,
      'isCameraOn': isCameraOn,
      'isScreenSharing': isScreenSharing,
      'isHandRaised': isHandRaised,
      'connectionInfo': connectionInfo,
    };
  }

  ParticipantModel copyWith({
    String? id,
    String? meetingId,
    String? userId,
    String? displayName,
    String? email,
    String? avatarUrl,
    ParticipantRole? role,
    ParticipantStatus? status,
    DateTime? joinedAt,
    DateTime? leftAt,
    bool? isMuted,
    bool? isCameraOn,
    bool? isScreenSharing,
    bool? isHandRaised,
    Map<String, dynamic>? connectionInfo,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      isHandRaised: isHandRaised ?? this.isHandRaised,
      connectionInfo: connectionInfo ?? this.connectionInfo,
    );
  }

  Duration? get sessionDuration {
    if (leftAt != null) {
      return leftAt!.difference(joinedAt);
    } else if (status == ParticipantStatus.joined) {
      return DateTime.now().difference(joinedAt);
    }
    return null;
  }

  bool get isHost => role == ParticipantRole.host;
  bool get isCoHost => role == ParticipantRole.coHost;
  bool get canModerate => isHost || isCoHost;
  bool get isActive => status == ParticipantStatus.joined;

  @override
  List<Object?> get props => [
        id,
        meetingId,
        userId,
        displayName,
        email,
        avatarUrl,
        role,
        status,
        joinedAt,
        leftAt,
        isMuted,
        isCameraOn,
        isScreenSharing,
        isHandRaised,
        connectionInfo,
      ];
}
