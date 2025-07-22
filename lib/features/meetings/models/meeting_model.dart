import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MeetingStatus {
  scheduled,
  active,
  ended,
  cancelled,
}

enum MeetingType {
  instant,
  scheduled,
  recurring,
}

class MeetingModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String hostId;
  final String hostName;
  final MeetingType type;
  final MeetingStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int maxParticipants;
  final List<String> participantIds;
  final List<String> invitedEmails;
  final String? meetingPassword;
  final bool isRecordingEnabled;
  final bool isChatEnabled;
  final bool isScreenShareEnabled;
  final Map<String, dynamic> settings;

  const MeetingModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.hostId,
    required this.hostName,
    required this.type,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.maxParticipants = 50,
    this.participantIds = const [],
    this.invitedEmails = const [],
    this.meetingPassword,
    this.isRecordingEnabled = false,
    this.isChatEnabled = true,
    this.isScreenShareEnabled = true,
    this.settings = const {},
  });

  factory MeetingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MeetingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      type: MeetingType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MeetingType.instant,
      ),
      status: MeetingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MeetingStatus.scheduled,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      scheduledAt: data['scheduledAt'] != null
          ? (data['scheduledAt'] as Timestamp).toDate()
          : null,
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      endedAt: data['endedAt'] != null
          ? (data['endedAt'] as Timestamp).toDate()
          : null,
      maxParticipants: data['maxParticipants'] ?? 50,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      invitedEmails: List<String>.from(data['invitedEmails'] ?? []),
      meetingPassword: data['meetingPassword'],
      isRecordingEnabled: data['isRecordingEnabled'] ?? false,
      isChatEnabled: data['isChatEnabled'] ?? true,
      isScreenShareEnabled: data['isScreenShareEnabled'] ?? true,
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'invitedEmails': invitedEmails,
      'meetingPassword': meetingPassword,
      'isRecordingEnabled': isRecordingEnabled,
      'isChatEnabled': isChatEnabled,
      'isScreenShareEnabled': isScreenShareEnabled,
      'settings': settings,
    };
  }

  MeetingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? hostId,
    String? hostName,
    MeetingType? type,
    MeetingStatus? status,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? maxParticipants,
    List<String>? participantIds,
    List<String>? invitedEmails,
    String? meetingPassword,
    bool? isRecordingEnabled,
    bool? isChatEnabled,
    bool? isScreenShareEnabled,
    Map<String, dynamic>? settings,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      invitedEmails: invitedEmails ?? this.invitedEmails,
      meetingPassword: meetingPassword ?? this.meetingPassword,
      isRecordingEnabled: isRecordingEnabled ?? this.isRecordingEnabled,
      isChatEnabled: isChatEnabled ?? this.isChatEnabled,
      isScreenShareEnabled: isScreenShareEnabled ?? this.isScreenShareEnabled,
      settings: settings ?? this.settings,
    );
  }

  String get meetingCode => id.substring(0, 8).toUpperCase();

  Duration? get duration {
    if (startedAt != null && endedAt != null) {
      return endedAt!.difference(startedAt!);
    }
    return null;
  }

  bool get isActive => status == MeetingStatus.active;
  bool get isScheduled => status == MeetingStatus.scheduled;
  bool get isEnded => status == MeetingStatus.ended;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        hostId,
        hostName,
        type,
        status,
        createdAt,
        scheduledAt,
        startedAt,
        endedAt,
        maxParticipants,
        participantIds,
        invitedEmails,
        meetingPassword,
        isRecordingEnabled,
        isChatEnabled,
        isScreenShareEnabled,
        settings,
      ];
}
