import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _messagesCollection => _firestore.collection('chat_messages');

  /// Send a message
  Future<ChatMessageModel> sendMessage(ChatMessageModel message) async {
    try {
      final docRef = await _messagesCollection.add(message.toFirestore());
      return message.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get messages for a meeting
  Stream<List<ChatMessageModel>> getMeetingMessages(String meetingId) {
    return _messagesCollection
        .where('meetingId', isEqualTo: meetingId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList());
  }

  /// Update message status
  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    try {
      await _messagesCollection.doc(messageId).update({
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Failed to update message status: $e');
    }
  }

  /// Edit message
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _messagesCollection.doc(messageId).update({
        'content': newContent,
        'editedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesCollection.doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  /// Get message by ID
  Future<ChatMessageModel?> getMessageById(String messageId) async {
    try {
      final doc = await _messagesCollection.doc(messageId).get();
      if (doc.exists) {
        return ChatMessageModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get message: $e');
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String meetingId, String userId) async {
    try {
      final batch = _firestore.batch();
      final messages = await _messagesCollection
          .where('meetingId', isEqualTo: meetingId)
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: MessageStatus.read.name)
          .get();

      for (final doc in messages.docs) {
        batch.update(doc.reference, {'status': MessageStatus.read.name});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get unread message count
  Future<int> getUnreadMessageCount(String meetingId, String userId) async {
    try {
      final snapshot = await _messagesCollection
          .where('meetingId', isEqualTo: meetingId)
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: MessageStatus.read.name)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread message count: $e');
    }
  }

  /// Search messages in meeting
  Future<List<ChatMessageModel>> searchMessages(String meetingId, String query) async {
    try {
      final snapshot = await _messagesCollection
          .where('meetingId', isEqualTo: meetingId)
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('content')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  /// Delete all messages for a meeting
  Future<void> deleteMeetingMessages(String meetingId) async {
    try {
      final batch = _firestore.batch();
      final messages = await _messagesCollection
          .where('meetingId', isEqualTo: meetingId)
          .get();

      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete meeting messages: $e');
    }
  }
}
