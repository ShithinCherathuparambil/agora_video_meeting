import 'package:equatable/equatable.dart';

enum MeetingStatus { waiting, active, ended }

class MeetingEntity extends Equatable {
  final String id;
  final String title;
  final String hostId;
  final String hostName;
  final MeetingStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int maxParticipants;
  final bool isRecording;
  final bool allowScreenShare;
  final bool allowChat;
  final String? password;

  const MeetingEntity({
    required this.id,
    required this.title,
    required this.hostId,
    required this.hostName,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.maxParticipants = 50,
    this.isRecording = false,
    this.allowScreenShare = true,
    this.allowChat = true,
    this.password,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        hostId,
        hostName,
        status,
        createdAt,
        startedAt,
        endedAt,
        maxParticipants,
        isRecording,
        allowScreenShare,
        allowChat,
        password,
      ];

  MeetingEntity copyWith({
    String? id,
    String? title,
    String? hostId,
    String? hostName,
    MeetingStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? maxParticipants,
    bool? isRecording,
    bool? allowScreenShare,
    bool? allowChat,
    String? password,
  }) {
    return MeetingEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isRecording: isRecording ?? this.isRecording,
      allowScreenShare: allowScreenShare ?? this.allowScreenShare,
      allowChat: allowChat ?? this.allowChat,
      password: password ?? this.password,
    );
  }

  bool get isActive => status == MeetingStatus.active;
  bool get isEnded => status == MeetingStatus.ended;
  bool get isWaiting => status == MeetingStatus.waiting;
  bool get hasPassword => password != null && password!.isNotEmpty;
  
  Duration? get duration {
    if (startedAt == null) return null;
    final endTime = endedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }
}

class ParticipantEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? photoUrl;
  final DateTime joinedAt;
  final bool isHost;
  final bool isMuted;
  final bool isCameraOff;
  final bool isScreenSharing;
  final bool isHandRaised;
  final DateTime? lastSeen;

  const ParticipantEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.photoUrl,
    required this.joinedAt,
    this.isHost = false,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isScreenSharing = false,
    this.isHandRaised = false,
    this.lastSeen,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        photoUrl,
        joinedAt,
        isHost,
        isMuted,
        isCameraOff,
        isScreenSharing,
        isHandRaised,
        lastSeen,
      ];

  ParticipantEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? photoUrl,
    DateTime? joinedAt,
    bool? isHost,
    bool? isMuted,
    bool? isCameraOff,
    bool? isScreenSharing,
    bool? isHandRaised,
    DateTime? lastSeen,
  }) {
    return ParticipantEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      joinedAt: joinedAt ?? this.joinedAt,
      isHost: isHost ?? this.isHost,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      isHandRaised: isHandRaised ?? this.isHandRaised,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Duration get sessionDuration {
    final endTime = lastSeen ?? DateTime.now();
    return endTime.difference(joinedAt);
  }
}
