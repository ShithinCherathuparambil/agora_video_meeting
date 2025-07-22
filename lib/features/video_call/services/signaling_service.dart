import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SignalingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createRoom(String roomId, RTCSessionDescription description) async {
    await _firestore.collection('rooms').doc(roomId).set({
      'offer': {
        'sdp': description.sdp,
        'type': description.type,
      },
    });
  }

  Future<void> joinRoom(String roomId, RTCSessionDescription description) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'answer': {
        'sdp': description.sdp,
        'type': description.type,
      },
    });
  }

  Stream<DocumentSnapshot> getRoomStream(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots();
  }

  Future<void> addCandidate(String roomId, RTCIceCandidate candidate) async {
    await _firestore.collection('rooms').doc(roomId).collection('candidates').add({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  Stream<QuerySnapshot> getCandidatesStream(String roomId) {
    return _firestore.collection('rooms').doc(roomId).collection('candidates').snapshots();
  }
}
