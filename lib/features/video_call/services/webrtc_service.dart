import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';
import '../models/webrtc_models.dart';
import 'signaling_service.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  final SignalingService _signalingService = SignalingService();
  final Map<String, PeerConnectionWrapper> _peerConnections = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  final Uuid _uuid = const Uuid();

  MediaStream? _localStream;
  String? _currentMeetingId;
  String? _currentUserId;

  // Stream controllers for UI updates
  final StreamController<Map<String, MediaStream>> _remoteStreamsController =
      StreamController<Map<String, MediaStream>>.broadcast();
  final StreamController<MediaStream?> _localStreamController =
      StreamController<MediaStream?>.broadcast();
  final StreamController<Map<String, RTCConnectionState>>
  _connectionStatesController =
      StreamController<Map<String, RTCConnectionState>>.broadcast();

  // Getters for streams
  Stream<Map<String, MediaStream>> get remoteStreams =>
      _remoteStreamsController.stream;
  Stream<MediaStream?> get localStream => _localStreamController.stream;
  Stream<Map<String, RTCConnectionState>> get connectionStates =>
      _connectionStatesController.stream;

  MediaStream? get currentLocalStream => _localStream;
  Map<String, MediaStream> get currentRemoteStreams {
    final streams = <String, MediaStream>{};
    for (final entry in _peerConnections.entries) {
      if (entry.value.remoteStream != null) {
        streams[entry.key] = entry.value.remoteStream!;
      }
    }
    return streams;
  }

  /// Initialize WebRTC for a meeting
  Future<void> initializeForMeeting({
    required String meetingId,
    required String userId,
    MediaConstraints constraints = const MediaConstraints(),
  }) async {
    try {
      _currentMeetingId = meetingId;
      _currentUserId = userId;

      // Get user media
      await _getUserMedia(constraints);

      // Start listening for signaling messages
      _startSignalingListeners();
    } catch (e) {
      throw Exception('Failed to initialize WebRTC: $e');
    }
  }

  /// Get user media (camera and microphone)
  Future<void> _getUserMedia(MediaConstraints constraints) async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
        constraints.toMap(),
      );
      _localStreamController.add(_localStream);
    } catch (e) {
      throw Exception('Failed to get user media: $e');
    }
  }

  /// Create peer connection for a specific user
  Future<RTCPeerConnection> _createPeerConnection(String peerId) async {
    try {
      final peerConnection = await createPeerConnection(
        WebRTCConfiguration.configuration,
      );

      // Add local stream to peer connection
      if (_localStream != null) {
        await peerConnection.addStream(_localStream!);
      }

      // Handle ICE candidates
      peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
        _handleIceCandidate(peerId, candidate);
      };

      // Handle remote stream
      peerConnection.onAddStream = (MediaStream stream) {
        _handleRemoteStream(peerId, stream);
      };

      // Handle connection state changes
      peerConnection.onConnectionState = (RTCPeerConnectionState state) {
        _handleConnectionStateChange(peerId, state);
      };

      return peerConnection;
    } catch (e) {
      throw Exception('Failed to create peer connection: $e');
    }
  }

  /// Handle ICE candidate
  void _handleIceCandidate(String peerId, RTCIceCandidate candidate) {
    if (_currentMeetingId != null && _currentUserId != null) {
      final candidateModel = RTCIceCandidateModel(
        candidate: candidate.candidate ?? '',
        sdpMid: candidate.sdpMid ?? '',
        sdpMLineIndex: candidate.sdpMLineIndex ?? 0,
        fromUserId: _currentUserId!,
        toUserId: peerId,
        meetingId: _currentMeetingId!,
        timestamp: DateTime.now(),
      );

      _signalingService
          .sendIceCandidate(
            meetingId: _currentMeetingId!,
            fromUserId: _currentUserId!,
            toUserId: peerId,
            candidate: candidateModel,
          )
          .catchError((e) {
            print('Failed to send ICE candidate: $e');
          });
    }
  }

  /// Handle remote stream
  void _handleRemoteStream(String peerId, MediaStream stream) {
    final wrapper = _peerConnections[peerId];
    if (wrapper != null) {
      _peerConnections[peerId] = wrapper.copyWith(remoteStream: stream);
      _remoteStreamsController.add(currentRemoteStreams);
    }
  }

  /// Handle connection state change
  void _handleConnectionStateChange(
    String peerId,
    RTCPeerConnectionState state,
  ) {
    RTCConnectionState connectionState;
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        connectionState = RTCConnectionState.connected;
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        connectionState = RTCConnectionState.connecting;
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        connectionState = RTCConnectionState.disconnected;
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        connectionState = RTCConnectionState.failed;
        break;
      default:
        connectionState = RTCConnectionState.disconnected;
    }

    final wrapper = _peerConnections[peerId];
    if (wrapper != null) {
      _peerConnections[peerId] = wrapper.copyWith(
        connectionState: connectionState,
      );

      final states = <String, RTCConnectionState>{};
      for (final entry in _peerConnections.entries) {
        states[entry.key] = entry.value.connectionState;
      }
      _connectionStatesController.add(states);
    }
  }

  /// Start listening for signaling messages
  void _startSignalingListeners() {
    if (_currentMeetingId == null || _currentUserId == null) return;

    // Listen for offers
    _subscriptions['offers'] = _signalingService
        .listenForOffers(meetingId: _currentMeetingId!, userId: _currentUserId!)
        .listen(_handleIncomingOffer);

    // Listen for answers
    _subscriptions['answers'] = _signalingService
        .listenForAnswers(
          meetingId: _currentMeetingId!,
          userId: _currentUserId!,
        )
        .listen(_handleIncomingAnswer);

    // Listen for ICE candidates
    _subscriptions['ice_candidates'] = _signalingService
        .listenForIceCandidates(
          meetingId: _currentMeetingId!,
          userId: _currentUserId!,
        )
        .listen(_handleIncomingIceCandidate);
  }

  /// Handle incoming offer
  Future<void> _handleIncomingOffer(RTCSessionDescriptionModel offer) async {
    try {
      final peerId = offer.fromUserId;

      // Create peer connection if it doesn't exist
      if (!_peerConnections.containsKey(peerId)) {
        final peerConnection = await _createPeerConnection(peerId);
        _peerConnections[peerId] = PeerConnectionWrapper(
          peerId: peerId,
          connection: peerConnection,
          localStream: _localStream,
          connectionState: RTCConnectionState.connecting,
          isInitiator: false,
        );
      }

      final wrapper = _peerConnections[peerId]!;

      // Set remote description
      await wrapper.connection.setRemoteDescription(
        offer.toRTCSessionDescription(),
      );

      // Create and send answer
      final answer = await wrapper.connection.createAnswer(
        WebRTCConfiguration.answerSdpConstraints,
      );
      await wrapper.connection.setLocalDescription(answer);

      final answerModel = RTCSessionDescriptionModel(
        type: answer.type!,
        sdp: answer.sdp!,
        fromUserId: _currentUserId!,
        toUserId: peerId,
        meetingId: _currentMeetingId!,
        timestamp: DateTime.now(),
      );

      await _signalingService.sendAnswer(
        meetingId: _currentMeetingId!,
        fromUserId: _currentUserId!,
        toUserId: peerId,
        answer: answerModel,
      );
    } catch (e) {
      print('Failed to handle incoming offer: $e');
    }
  }

  /// Handle incoming answer
  Future<void> _handleIncomingAnswer(RTCSessionDescriptionModel answer) async {
    try {
      final peerId = answer.fromUserId;
      final wrapper = _peerConnections[peerId];

      if (wrapper != null) {
        await wrapper.connection.setRemoteDescription(
          answer.toRTCSessionDescription(),
        );
      }
    } catch (e) {
      print('Failed to handle incoming answer: $e');
    }
  }

  /// Handle incoming ICE candidate
  Future<void> _handleIncomingIceCandidate(
    RTCIceCandidateModel candidate,
  ) async {
    try {
      final peerId = candidate.fromUserId;
      final wrapper = _peerConnections[peerId];

      if (wrapper != null) {
        await wrapper.connection.addCandidate(candidate.toRTCIceCandidate());
      }
    } catch (e) {
      print('Failed to handle incoming ICE candidate: $e');
    }
  }

  /// Connect to a specific peer (initiate call)
  Future<void> connectToPeer(String peerId) async {
    try {
      if (_currentMeetingId == null || _currentUserId == null) {
        throw Exception('WebRTC not initialized');
      }

      // Create peer connection if it doesn't exist
      if (!_peerConnections.containsKey(peerId)) {
        final peerConnection = await _createPeerConnection(peerId);
        _peerConnections[peerId] = PeerConnectionWrapper(
          peerId: peerId,
          connection: peerConnection,
          localStream: _localStream,
          connectionState: RTCConnectionState.connecting,
          isInitiator: true,
        );
      }

      final wrapper = _peerConnections[peerId]!;

      // Create and send offer
      final offer = await wrapper.connection.createOffer(
        WebRTCConfiguration.offerSdpConstraints,
      );
      await wrapper.connection.setLocalDescription(offer);

      final offerModel = RTCSessionDescriptionModel(
        type: offer.type!,
        sdp: offer.sdp!,
        fromUserId: _currentUserId!,
        toUserId: peerId,
        meetingId: _currentMeetingId!,
        timestamp: DateTime.now(),
      );

      await _signalingService.sendOffer(
        meetingId: _currentMeetingId!,
        fromUserId: _currentUserId!,
        toUserId: peerId,
        offer: offerModel,
      );
    } catch (e) {
      throw Exception('Failed to connect to peer: $e');
    }
  }

  /// Disconnect from a specific peer
  Future<void> disconnectFromPeer(String peerId) async {
    try {
      final wrapper = _peerConnections[peerId];
      if (wrapper != null) {
        await wrapper.connection.close();
        _peerConnections.remove(peerId);
        _remoteStreamsController.add(currentRemoteStreams);

        final states = <String, RTCConnectionState>{};
        for (final entry in _peerConnections.entries) {
          states[entry.key] = entry.value.connectionState;
        }
        _connectionStatesController.add(states);
      }
    } catch (e) {
      print('Failed to disconnect from peer: $e');
    }
  }

  /// Toggle local video
  Future<void> toggleVideo() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final enabled = videoTracks.first.enabled;
        videoTracks.first.enabled = !enabled;
      }
    }
  }

  /// Toggle local audio
  Future<void> toggleAudio() async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final enabled = audioTracks.first.enabled;
        audioTracks.first.enabled = !enabled;
      }
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks.first);
      }
    }
  }

  /// Get current video enabled state
  bool get isVideoEnabled {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        return videoTracks.first.enabled;
      }
    }
    return false;
  }

  /// Get current audio enabled state
  bool get isAudioEnabled {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        return audioTracks.first.enabled;
      }
    }
    return false;
  }

  /// Clean up and dispose
  Future<void> dispose() async {
    try {
      // Cancel all subscriptions
      for (final subscription in _subscriptions.values) {
        await subscription.cancel();
      }
      _subscriptions.clear();

      // Close all peer connections
      for (final wrapper in _peerConnections.values) {
        await wrapper.connection.close();
      }
      _peerConnections.clear();

      // Stop local stream
      if (_localStream != null) {
        await _localStream!.dispose();
        _localStream = null;
      }

      // Close stream controllers
      await _remoteStreamsController.close();
      await _localStreamController.close();
      await _connectionStatesController.close();

      // Dispose signaling service
      _signalingService.dispose();

      _currentMeetingId = null;
      _currentUserId = null;
    } catch (e) {
      print('Error during WebRTC disposal: $e');
    }
  }
}
