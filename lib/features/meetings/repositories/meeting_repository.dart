import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting_model.dart';
import '../models/participant_model.dart';

class MeetingRepository {
  final FirebaseFirestore _firestore;

  MeetingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _meetingsCollection => _firestore.collection('meetings');
  CollectionReference get _participantsCollection => _firestore.collection('participants');

  /// Create a new meeting
  Future<MeetingModel> createMeeting(MeetingModel meeting) async {
    try {
      final docRef = await _meetingsCollection.add(meeting.toFirestore());
      final createdMeeting = meeting.copyWith(id: docRef.id);
      
      // Add host as first participant
      await addParticipant(ParticipantModel(
        id: '',
        meetingId: docRef.id,
        userId: meeting.hostId,
        displayName: meeting.hostName,
        email: '', // Will be filled from user data
        role: ParticipantRole.host,
        status: ParticipantStatus.joined,
        joinedAt: DateTime.now(),
      ));
      
      return createdMeeting;
    } catch (e) {
      throw Exception('Failed to create meeting: $e');
    }
  }

  /// Get meeting by ID
  Future<MeetingModel?> getMeetingById(String meetingId) async {
    try {
      final doc = await _meetingsCollection.doc(meetingId).get();
      if (doc.exists) {
        return MeetingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get meeting: $e');
    }
  }

  /// Get meeting by code
  Future<MeetingModel?> getMeetingByCode(String meetingCode) async {
    try {
      final query = await _meetingsCollection
          .where('id', isGreaterThanOrEqualTo: meetingCode.toLowerCase())
          .where('id', isLessThan: '${meetingCode.toLowerCase()}z')
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return MeetingModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find meeting with code: $e');
    }
  }

  /// Update meeting
  Future<void> updateMeeting(String meetingId, Map<String, dynamic> updates) async {
    try {
      await _meetingsCollection.doc(meetingId).update(updates);
    } catch (e) {
      throw Exception('Failed to update meeting: $e');
    }
  }

  /// Start meeting
  Future<void> startMeeting(String meetingId) async {
    try {
      await updateMeeting(meetingId, {
        'status': MeetingStatus.active.name,
        'startedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to start meeting: $e');
    }
  }

  /// End meeting
  Future<void> endMeeting(String meetingId) async {
    try {
      await updateMeeting(meetingId, {
        'status': MeetingStatus.ended.name,
        'endedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to end meeting: $e');
    }
  }

  /// Get user's meetings
  Stream<List<MeetingModel>> getUserMeetings(String userId) {
    return _meetingsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MeetingModel.fromFirestore(doc))
            .toList());
  }

  /// Get hosted meetings
  Stream<List<MeetingModel>> getHostedMeetings(String hostId) {
    return _meetingsCollection
        .where('hostId', isEqualTo: hostId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MeetingModel.fromFirestore(doc))
            .toList());
  }

  /// Add participant to meeting
  Future<ParticipantModel> addParticipant(ParticipantModel participant) async {
    try {
      final docRef = await _participantsCollection.add(participant.toFirestore());
      
      // Update meeting participant list
      await _meetingsCollection.doc(participant.meetingId).update({
        'participantIds': FieldValue.arrayUnion([participant.userId]),
      });
      
      return participant.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to add participant: $e');
    }
  }

  /// Remove participant from meeting
  Future<void> removeParticipant(String participantId, String meetingId, String userId) async {
    try {
      await _participantsCollection.doc(participantId).update({
        'status': ParticipantStatus.left.name,
        'leftAt': Timestamp.now(),
      });
      
      // Update meeting participant list
      await _meetingsCollection.doc(meetingId).update({
        'participantIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to remove participant: $e');
    }
  }

  /// Get meeting participants
  Stream<List<ParticipantModel>> getMeetingParticipants(String meetingId) {
    return _participantsCollection
        .where('meetingId', isEqualTo: meetingId)
        .where('status', isEqualTo: ParticipantStatus.joined.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParticipantModel.fromFirestore(doc))
            .toList());
  }

  /// Update participant status
  Future<void> updateParticipant(String participantId, Map<String, dynamic> updates) async {
    try {
      await _participantsCollection.doc(participantId).update(updates);
    } catch (e) {
      throw Exception('Failed to update participant: $e');
    }
  }

  /// Delete meeting (only for host)
  Future<void> deleteMeeting(String meetingId) async {
    try {
      // Delete all participants
      final participants = await _participantsCollection
          .where('meetingId', isEqualTo: meetingId)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in participants.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete meeting
      batch.delete(_meetingsCollection.doc(meetingId));
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete meeting: $e');
    }
  }

  /// Search meetings by title
  Future<List<MeetingModel>> searchMeetings(String query, String userId) async {
    try {
      final snapshot = await _meetingsCollection
          .where('participantIds', arrayContains: userId)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();
      
      return snapshot.docs
          .map((doc) => MeetingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search meetings: $e');
    }
  }
}
