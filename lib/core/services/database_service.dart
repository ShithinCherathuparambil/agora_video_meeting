import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/meetings/models/meeting_model.dart';
import '../../features/meetings/models/participant_model.dart';
import '../../features/chat/models/chat_message_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get meetings => _firestore.collection('meetings');
  CollectionReference get participants => _firestore.collection('participants');
  CollectionReference get chatMessages => _firestore.collection('chat_messages');
  CollectionReference get signaling => _firestore.collection('signaling');

  /// Initialize user document in Firestore
  Future<void> createUserDocument(UserModel user) async {
    try {
      await users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  /// Get user document
  Future<UserModel?> getUserDocument(String userId) async {
    try {
      final doc = await users.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user document: $e');
    }
  }

  /// Update user document
  Future<void> updateUserDocument(String userId, Map<String, dynamic> data) async {
    try {
      await users.doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user document: $e');
    }
  }

  /// Create meeting with transaction
  Future<MeetingModel> createMeetingWithTransaction(MeetingModel meeting) async {
    try {
      return await _firestore.runTransaction<MeetingModel>((transaction) async {
        // Create meeting document
        final meetingRef = meetings.doc();
        final meetingWithId = meeting.copyWith(id: meetingRef.id);
        transaction.set(meetingRef, meetingWithId.toFirestore());

        // Create host participant
        final participantRef = participants.doc();
        final hostParticipant = ParticipantModel(
          id: participantRef.id,
          meetingId: meetingRef.id,
          userId: meeting.hostId,
          displayName: meeting.hostName,
          email: '', // Will be filled from user data
          role: ParticipantRole.host,
          status: ParticipantStatus.joined,
          joinedAt: DateTime.now(),
        );
        transaction.set(participantRef, hostParticipant.toFirestore());

        return meetingWithId;
      });
    } catch (e) {
      throw Exception('Failed to create meeting: $e');
    }
  }

  /// Join meeting with transaction
  Future<ParticipantModel> joinMeetingWithTransaction({
    required String meetingId,
    required String userId,
    required String displayName,
    required String email,
  }) async {
    try {
      return await _firestore.runTransaction<ParticipantModel>((transaction) async {
        // Check if meeting exists and is active
        final meetingDoc = await transaction.get(meetings.doc(meetingId));
        if (!meetingDoc.exists) {
          throw Exception('Meeting not found');
        }

        final meeting = MeetingModel.fromFirestore(meetingDoc);
        if (meeting.status == MeetingStatus.ended) {
          throw Exception('Meeting has ended');
        }

        // Check if user is already a participant
        final existingParticipant = await participants
            .where('meetingId', isEqualTo: meetingId)
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: ParticipantStatus.joined.name)
            .limit(1)
            .get();

        if (existingParticipant.docs.isNotEmpty) {
          return ParticipantModel.fromFirestore(existingParticipant.docs.first);
        }

        // Add participant
        final participantRef = participants.doc();
        final participant = ParticipantModel(
          id: participantRef.id,
          meetingId: meetingId,
          userId: userId,
          displayName: displayName,
          email: email,
          role: ParticipantRole.participant,
          status: ParticipantStatus.joined,
          joinedAt: DateTime.now(),
        );

        transaction.set(participantRef, participant.toFirestore());

        // Update meeting participant list
        transaction.update(meetings.doc(meetingId), {
          'participantIds': FieldValue.arrayUnion([userId]),
        });

        return participant;
      });
    } catch (e) {
      throw Exception('Failed to join meeting: $e');
    }
  }

  /// Leave meeting with transaction
  Future<void> leaveMeetingWithTransaction({
    required String meetingId,
    required String userId,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Find participant document
        final participantQuery = await participants
            .where('meetingId', isEqualTo: meetingId)
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: ParticipantStatus.joined.name)
            .limit(1)
            .get();

        if (participantQuery.docs.isEmpty) {
          throw Exception('Participant not found');
        }

        final participantDoc = participantQuery.docs.first;
        
        // Update participant status
        transaction.update(participantDoc.reference, {
          'status': ParticipantStatus.left.name,
          'leftAt': Timestamp.now(),
        });

        // Update meeting participant list
        transaction.update(meetings.doc(meetingId), {
          'participantIds': FieldValue.arrayRemove([userId]),
        });
      });
    } catch (e) {
      throw Exception('Failed to leave meeting: $e');
    }
  }

  /// Send system message
  Future<void> sendSystemMessage({
    required String meetingId,
    required String content,
  }) async {
    try {
      final message = ChatMessageModel(
        id: '',
        meetingId: meetingId,
        senderId: 'system',
        senderName: 'System',
        content: content,
        type: MessageType.system,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      await chatMessages.add(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to send system message: $e');
    }
  }

  /// Get meeting statistics
  Future<Map<String, dynamic>> getMeetingStatistics(String meetingId) async {
    try {
      final meeting = await meetings.doc(meetingId).get();
      if (!meeting.exists) {
        throw Exception('Meeting not found');
      }

      final participantCount = await participants
          .where('meetingId', isEqualTo: meetingId)
          .where('status', isEqualTo: ParticipantStatus.joined.name)
          .get();

      final messageCount = await chatMessages
          .where('meetingId', isEqualTo: meetingId)
          .get();

      final meetingData = MeetingModel.fromFirestore(meeting);

      return {
        'meetingId': meetingId,
        'title': meetingData.title,
        'status': meetingData.status.name,
        'participantCount': participantCount.docs.length,
        'messageCount': messageCount.docs.length,
        'duration': meetingData.duration?.inMinutes ?? 0,
        'createdAt': meetingData.createdAt,
        'startedAt': meetingData.startedAt,
        'endedAt': meetingData.endedAt,
      };
    } catch (e) {
      throw Exception('Failed to get meeting statistics: $e');
    }
  }

  /// Clean up ended meetings (remove old data)
  Future<void> cleanupEndedMeetings({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      final oldMeetings = await meetings
          .where('status', isEqualTo: MeetingStatus.ended.name)
          .where('endedAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      
      for (final meetingDoc in oldMeetings.docs) {
        final meetingId = meetingDoc.id;
        
        // Delete participants
        final participantDocs = await participants
            .where('meetingId', isEqualTo: meetingId)
            .get();
        
        for (final participantDoc in participantDocs.docs) {
          batch.delete(participantDoc.reference);
        }
        
        // Delete chat messages
        final messageDocs = await chatMessages
            .where('meetingId', isEqualTo: meetingId)
            .get();
        
        for (final messageDoc in messageDocs.docs) {
          batch.delete(messageDoc.reference);
        }
        
        // Delete meeting
        batch.delete(meetingDoc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cleanup ended meetings: $e');
    }
  }

  /// Batch operations helper
  WriteBatch get batch => _firestore.batch();
  
  /// Transaction helper
  Future<T> runTransaction<T>(TransactionHandler<T> updateFunction) {
    return _firestore.runTransaction<T>(updateFunction);
  }
}
