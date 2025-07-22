import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gooteam_stream/features/chat/models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getMessages(String meetingId) {
    return _firestore
        .collection('rooms')
        .doc(meetingId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  Future<void> sendMessage(String meetingId, String senderId, String message) async {
    await _firestore
        .collection('rooms')
        .doc(meetingId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
