import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/webrtc_models.dart';

enum VideoCallStatus {
  initial,
  initializing,
  ready,
  connecting,
  connected,
  disconnected,
  error,
}

class VideoCallState extends Equatable {
  final VideoCallStatus status;
  final String? meetingId;
  final String? userId;
  final MediaStream? localStream;
  final Map<String, MediaStream> remoteStreams;
  final Map<String, RTCConnectionState> connectionStates;
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final String? errorMessage;

  const VideoCallState({
    this.status = VideoCallStatus.initial,
    this.meetingId,
    this.userId,
    this.localStream,
    this.remoteStreams = const {},
    this.connectionStates = const {},
    this.isVideoEnabled = true,
    this.isAudioEnabled = true,
    this.errorMessage,
  });

  VideoCallState copyWith({
    VideoCallStatus? status,
    String? meetingId,
    String? userId,
    MediaStream? localStream,
    Map<String, MediaStream>? remoteStreams,
    Map<String, RTCConnectionState>? connectionStates,
    bool? isVideoEnabled,
    bool? isAudioEnabled,
    String? errorMessage,
  }) {
    return VideoCallState(
      status: status ?? this.status,
      meetingId: meetingId ?? this.meetingId,
      userId: userId ?? this.userId,
      localStream: localStream ?? this.localStream,
      remoteStreams: remoteStreams ?? this.remoteStreams,
      connectionStates: connectionStates ?? this.connectionStates,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isInitialized => status != VideoCallStatus.initial;
  bool get isReady => status == VideoCallStatus.ready;
  bool get isConnected => status == VideoCallStatus.connected;
  bool get hasError => status == VideoCallStatus.error;
  bool get hasRemoteStreams => remoteStreams.isNotEmpty;

  int get connectedPeersCount {
    return connectionStates.values
        .where((state) => state == RTCConnectionState.connected)
        .length;
  }

  List<String> get connectedPeerIds {
    return connectionStates.entries
        .where((entry) => entry.value == RTCConnectionState.connected)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  List<Object?> get props => [
        status,
        meetingId,
        userId,
        localStream,
        remoteStreams,
        connectionStates,
        isVideoEnabled,
        isAudioEnabled,
        errorMessage,
      ];
}
