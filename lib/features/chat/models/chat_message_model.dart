import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  image,
  file,
  system,
  emoji,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessageModel extends Equatable {
  final String id;
  final String meetingId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? editedAt;
  final String? replyToMessageId;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final Map<String, dynamic> metadata;

  const ChatMessageModel({
    required this.id,
    required this.meetingId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.editedAt,
    this.replyToMessageId,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.metadata = const {},
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      meetingId: data['meetingId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatarUrl: data['senderAvatarUrl'],
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      editedAt: data['editedAt'] != null
          ? (data['editedAt'] as Timestamp).toDate()
          : null,
      replyToMessageId: data['replyToMessageId'],
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'meetingId': meetingId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'replyToMessageId': replyToMessageId,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'metadata': metadata,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? meetingId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? editedAt,
    String? replyToMessageId,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isEdited => editedAt != null;
  bool get isReply => replyToMessageId != null;
  bool get hasFile => fileUrl != null;
  bool get isSystemMessage => type == MessageType.system;

  String get formattedFileSize {
    if (fileSize == null) return '';
    
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = fileSize!.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  @override
  List<Object?> get props => [
        id,
        meetingId,
        senderId,
        senderName,
        senderAvatarUrl,
        content,
        type,
        status,
        timestamp,
        editedAt,
        replyToMessageId,
        fileUrl,
        fileName,
        fileSize,
        metadata,
      ];
}
