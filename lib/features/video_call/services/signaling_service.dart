import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/webrtc_models.dart';

class SignalingService {
  final FirebaseFirestore _firestore;
  final Map<String, StreamSubscription> _subscriptions = {};

  SignalingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Send offer to specific user
  Future<void> sendOffer({
    required String meetingId,
    required String fromUserId,
    required String toUserId,
    required RTCSessionDescriptionModel offer,
  }) async {
    try {
      await _firestore
          .collection('signaling')
          .doc(meetingId)
          .collection('offers')
          .add(offer.toMap());
    } catch (e) {
      throw Exception('Failed to send offer: $e');
    }
  }

  /// Send answer to specific user
  Future<void> sendAnswer({
    required String meetingId,
    required String fromUserId,
    required String toUserId,
    required RTCSessionDescriptionModel answer,
  }) async {
    try {
      await _firestore
          .collection('signaling')
          .doc(meetingId)
          .collection('answers')
          .add(answer.toMap());
    } catch (e) {
      throw Exception('Failed to send answer: $e');
    }
  }

  /// Send ICE candidate
  Future<void> sendIceCandidate({
    required String meetingId,
    required String fromUserId,
    required String toUserId,
    required RTCIceCandidateModel candidate,
  }) async {
    try {
      await _firestore
          .collection('signaling')
          .doc(meetingId)
          .collection('ice_candidates')
          .add(candidate.toMap());
    } catch (e) {
      throw Exception('Failed to send ICE candidate: $e');
    }
  }

  /// Listen for offers directed to current user
  Stream<RTCSessionDescriptionModel> listenForOffers({
    required String meetingId,
    required String userId,
  }) {
    final controller = StreamController<RTCSessionDescriptionModel>();
    
    final subscription = _firestore
        .collection('signaling')
        .doc(meetingId)
        .collection('offers')
        .where('toUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final offer = RTCSessionDescriptionModel.fromMap(data);
          controller.add(offer);
          
          // Clean up the processed offer
          change.doc.reference.delete().catchError((e) {
            print('Failed to delete processed offer: $e');
          });
        }
      }
    });

    _subscriptions['offers_$meetingId'] = subscription;
    
    controller.onCancel = () {
      subscription.cancel();
      _subscriptions.remove('offers_$meetingId');
    };

    return controller.stream;
  }

  /// Listen for answers directed to current user
  Stream<RTCSessionDescriptionModel> listenForAnswers({
    required String meetingId,
    required String userId,
  }) {
    final controller = StreamController<RTCSessionDescriptionModel>();
    
    final subscription = _firestore
        .collection('signaling')
        .doc(meetingId)
        .collection('answers')
        .where('toUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final answer = RTCSessionDescriptionModel.fromMap(data);
          controller.add(answer);
          
          // Clean up the processed answer
          change.doc.reference.delete().catchError((e) {
            print('Failed to delete processed answer: $e');
          });
        }
      }
    });

    _subscriptions['answers_$meetingId'] = subscription;
    
    controller.onCancel = () {
      subscription.cancel();
      _subscriptions.remove('answers_$meetingId');
    };

    return controller.stream;
  }

  /// Listen for ICE candidates directed to current user
  Stream<RTCIceCandidateModel> listenForIceCandidates({
    required String meetingId,
    required String userId,
  }) {
    final controller = StreamController<RTCIceCandidateModel>();
    
    final subscription = _firestore
        .collection('signaling')
        .doc(meetingId)
        .collection('ice_candidates')
        .where('toUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final candidate = RTCIceCandidateModel.fromMap(data);
          controller.add(candidate);
          
          // Clean up the processed candidate
          change.doc.reference.delete().catchError((e) {
            print('Failed to delete processed ICE candidate: $e');
          });
        }
      }
    });

    _subscriptions['ice_candidates_$meetingId'] = subscription;
    
    controller.onCancel = () {
      subscription.cancel();
      _subscriptions.remove('ice_candidates_$meetingId');
    };

    return controller.stream;
  }

  /// Clean up signaling data for a meeting
  Future<void> cleanupSignalingData(String meetingId) async {
    try {
      final batch = _firestore.batch();
      
      // Delete offers
      final offers = await _firestore
          .collection('signaling')
          .doc(meetingId)
          .collection('offers')
          .get();
      
      for (final doc in offers.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete answers
      final answers = await _firestore
          .collection('signaling')
          .doc(meetingId)
          .collection('answers')
          .get();
      
      for (final doc in answers.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete ICE candidates
      final candidates = await _firestore
          .collection('signaling')
          .doc(meetingId)
          .collection('ice_candidates')
          .get();
      
      for (final doc in candidates.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cleanup signaling data: $e');
    }
  }

  /// Cancel all subscriptions
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Cancel specific subscription
  void cancelSubscription(String key) {
    final subscription = _subscriptions[key];
    if (subscription != null) {
      subscription.cancel();
      _subscriptions.remove(key);
    }
  }

  /// Dispose of the service
  void dispose() {
    cancelAllSubscriptions();
  }
}
