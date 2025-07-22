part of 'video_call_bloc.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();

  @override
  List<Object> get props => [];
}

class VideoCallInitialize extends VideoCallEvent {
  final String meetingId;
  final String userId;

  const VideoCallInitialize({
    required this.meetingId,
    required this.userId,
  });

  @override
  List<Object> get props => [meetingId, userId];
}

class VideoCallCreateOffer extends VideoCallEvent {
  final String meetingId;

  const VideoCallCreateOffer({required this.meetingId});

  @override
  List<Object> get props => [meetingId];
}

class VideoCallCreateAnswer extends VideoCallEvent {
  final String meetingId;

  const VideoCallCreateAnswer({required this.meetingId});

  @override
  List<Object> get props => [meetingId];
}

class VideoCallSetRemoteDescription extends VideoCallEvent {
  final RTCSessionDescription description;

  const VideoCallSetRemoteDescription({required this.description});

  @override
  List<Object> get props => [description];
}

class VideoCallAddCandidate extends VideoCallEvent {
  final RTCIceCandidate candidate;

  const VideoCallAddCandidate({required this.candidate});

  @override
  List<Object> get props => [candidate];
}

class VideoCallHangUp extends VideoCallEvent {}

class VideoCallToggleScreenShare extends VideoCallEvent {}

class VideoCallToggleRecording extends VideoCallEvent {}

class VideoCallToggleVirtualBackground extends VideoCallEvent {}
