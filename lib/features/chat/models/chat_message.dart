import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  @override
  List<Object> get props => [id, senderId, message, timestamp];

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
