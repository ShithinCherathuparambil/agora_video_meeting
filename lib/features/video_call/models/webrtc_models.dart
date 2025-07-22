import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// WebRTC connection state
enum RTCConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// Media stream type
enum MediaStreamType {
  local,
  remote,
}

/// WebRTC offer/answer model
class RTCSessionDescriptionModel extends Equatable {
  final String type; // 'offer' or 'answer'
  final String sdp;
  final String fromUserId;
  final String toUserId;
  final String meetingId;
  final DateTime timestamp;

  const RTCSessionDescriptionModel({
    required this.type,
    required this.sdp,
    required this.fromUserId,
    required this.toUserId,
    required this.meetingId,
    required this.timestamp,
  });

  factory RTCSessionDescriptionModel.fromMap(Map<String, dynamic> map) {
    return RTCSessionDescriptionModel(
      type: map['type'] ?? '',
      sdp: map['sdp'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      meetingId: map['meetingId'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'sdp': sdp,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'meetingId': meetingId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  RTCSessionDescription toRTCSessionDescription() {
    return RTCSessionDescription(sdp, type);
  }

  @override
  List<Object> get props => [type, sdp, fromUserId, toUserId, meetingId, timestamp];
}

/// ICE candidate model
class RTCIceCandidateModel extends Equatable {
  final String candidate;
  final String sdpMid;
  final int sdpMLineIndex;
  final String fromUserId;
  final String toUserId;
  final String meetingId;
  final DateTime timestamp;

  const RTCIceCandidateModel({
    required this.candidate,
    required this.sdpMid,
    required this.sdpMLineIndex,
    required this.fromUserId,
    required this.toUserId,
    required this.meetingId,
    required this.timestamp,
  });

  factory RTCIceCandidateModel.fromMap(Map<String, dynamic> map) {
    return RTCIceCandidateModel(
      candidate: map['candidate'] ?? '',
      sdpMid: map['sdpMid'] ?? '',
      sdpMLineIndex: map['sdpMLineIndex'] ?? 0,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      meetingId: map['meetingId'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'candidate': candidate,
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'meetingId': meetingId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  RTCIceCandidate toRTCIceCandidate() {
    return RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);
  }

  @override
  List<Object> get props => [
        candidate,
        sdpMid,
        sdpMLineIndex,
        fromUserId,
        toUserId,
        meetingId,
        timestamp,
      ];
}

/// Peer connection wrapper
class PeerConnectionWrapper extends Equatable {
  final String peerId;
  final RTCPeerConnection connection;
  final MediaStream? localStream;
  final MediaStream? remoteStream;
  final RTCConnectionState connectionState;
  final bool isInitiator;

  const PeerConnectionWrapper({
    required this.peerId,
    required this.connection,
    this.localStream,
    this.remoteStream,
    required this.connectionState,
    required this.isInitiator,
  });

  PeerConnectionWrapper copyWith({
    String? peerId,
    RTCPeerConnection? connection,
    MediaStream? localStream,
    MediaStream? remoteStream,
    RTCConnectionState? connectionState,
    bool? isInitiator,
  }) {
    return PeerConnectionWrapper(
      peerId: peerId ?? this.peerId,
      connection: connection ?? this.connection,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      connectionState: connectionState ?? this.connectionState,
      isInitiator: isInitiator ?? this.isInitiator,
    );
  }

  @override
  List<Object?> get props => [
        peerId,
        connection,
        localStream,
        remoteStream,
        connectionState,
        isInitiator,
      ];
}

/// Media constraints configuration
class MediaConstraints {
  final bool video;
  final bool audio;
  final Map<String, dynamic> videoConstraints;
  final Map<String, dynamic> audioConstraints;

  const MediaConstraints({
    this.video = true,
    this.audio = true,
    this.videoConstraints = const {
      'width': {'min': 640, 'ideal': 1280, 'max': 1920},
      'height': {'min': 480, 'ideal': 720, 'max': 1080},
      'frameRate': {'min': 15, 'ideal': 30, 'max': 60},
    },
    this.audioConstraints = const {
      'echoCancellation': true,
      'noiseSuppression': true,
      'autoGainControl': true,
    },
  });

  Map<String, dynamic> toMap() {
    return {
      'audio': audio ? audioConstraints : false,
      'video': video ? videoConstraints : false,
    };
  }
}

/// WebRTC configuration
class WebRTCConfiguration {
  static const List<Map<String, String>> iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
  ];

  static const Map<String, dynamic> configuration = {
    'iceServers': iceServers,
    'sdpSemantics': 'unified-plan',
  };

  static const Map<String, dynamic> offerSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  static const Map<String, dynamic> answerSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };
}
