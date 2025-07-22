import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/webrtc_models.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();

  @override
  List<Object?> get props => [];
}

class VideoCallInitialize extends VideoCallEvent {
  final String meetingId;
  final String userId;
  final MediaConstraints constraints;

  const VideoCallInitialize({
    required this.meetingId,
    required this.userId,
    this.constraints = const MediaConstraints(),
  });

  @override
  List<Object> get props => [meetingId, userId, constraints];
}

class VideoCallConnectToPeer extends VideoCallEvent {
  final String peerId;

  const VideoCallConnectToPeer({required this.peerId});

  @override
  List<Object> get props => [peerId];
}

class VideoCallDisconnectFromPeer extends VideoCallEvent {
  final String peerId;

  const VideoCallDisconnectFromPeer({required this.peerId});

  @override
  List<Object> get props => [peerId];
}

class VideoCallToggleVideo extends VideoCallEvent {
  const VideoCallToggleVideo();
}

class VideoCallToggleAudio extends VideoCallEvent {
  const VideoCallToggleAudio();
}

class VideoCallSwitchCamera extends VideoCallEvent {
  const VideoCallSwitchCamera();
}

class VideoCallLocalStreamUpdated extends VideoCallEvent {
  final MediaStream? stream;

  const VideoCallLocalStreamUpdated({this.stream});

  @override
  List<Object?> get props => [stream];
}

class VideoCallRemoteStreamsUpdated extends VideoCallEvent {
  final Map<String, MediaStream> streams;

  const VideoCallRemoteStreamsUpdated({required this.streams});

  @override
  List<Object> get props => [streams];
}

class VideoCallConnectionStatesUpdated extends VideoCallEvent {
  final Map<String, RTCConnectionState> states;

  const VideoCallConnectionStatesUpdated({required this.states});

  @override
  List<Object> get props => [states];
}

class VideoCallEnd extends VideoCallEvent {
  const VideoCallEnd();
}

class VideoCallError extends VideoCallEvent {
  final String message;

  const VideoCallError({required this.message});

  @override
  List<Object> get props => [message];
}
