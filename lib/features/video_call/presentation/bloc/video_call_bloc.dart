import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gooteam_stream/features/video_call/services/signaling_service.dart';

part 'video_call_event.dart';
part 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final SignalingService _signalingService;
  RTCPeerConnection? _peerConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  StreamSubscription? _roomSubscription;
  StreamSubscription? _candidatesSubscription;

  bool _isScreenSharing = false;

  VideoCallBloc({required SignalingService signalingService})
      : _signalingService = signalingService,
        super(const VideoCallState()) {
    on<VideoCallInitialize>(_onVideoCallInitialize);
    on<VideoCallCreateOffer>(_onVideoCallCreateOffer);
    on<VideoCallCreateAnswer>(_onVideoCallCreateAnswer);
    on<VideoCallSetRemoteDescription>(_onVideoCallSetRemoteDescription);
    on<VideoCallAddCandidate>(_onVideoCallAddCandidate);
    on<VideoCallHangUp>(_onVideoCallHangUp);
    on<VideoCallToggleScreenShare>(_onVideoCallToggleScreenShare);
  }

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> _onVideoCallInitialize(
    VideoCallInitialize event,
    Emitter<VideoCallState> emit,
  ) async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection?.onIceCandidate = (candidate) {
      _signalingService.addCandidate(event.meetingId, candidate);
    };

    _peerConnection?.onTrack = (trackEvent) {
      if (trackEvent.track.kind == 'video') {
        _remoteRenderer.srcObject = trackEvent.streams[0];
      }
    };

    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = stream;
    stream.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, stream);
    });

    _roomSubscription = _signalingService.getRoomStream(event.meetingId).listen((snapshot) async {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        if (data['answer'] != null) {
          final answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );
          add(VideoCallSetRemoteDescription(description: answer));
        }
      }
    });

    _candidatesSubscription =
        _signalingService.getCandidatesStream(event.meetingId).listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
          add(VideoCallAddCandidate(candidate: candidate));
        }
      }
    });
  }

  Future<void> _onVideoCallCreateOffer(
    VideoCallCreateOffer event,
    Emitter<VideoCallState> emit,
  ) async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    // TODO: Pass meetingId
    // await _signalingService.createRoom(meetingId, offer);
  }

  Future<void> _onVideoCallCreateAnswer(
    VideoCallCreateAnswer event,
    Emitter<VideoCallState> emit,
  ) async {
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    // TODO: Pass meetingId
    // await _signalingService.joinRoom(meetingId, answer);
  }

  Future<void> _onVideoCallSetRemoteDescription(
    VideoCallSetRemoteDescription event,
    Emitter<VideoCallState> emit,
  ) async {
    await _peerConnection!.setRemoteDescription(event.description);
  }

  Future<void> _onVideoCallAddCandidate(
    VideoCallAddCandidate event,
    Emitter<VideoCallState> emit,
  ) async {
    await _peerConnection!.addCandidate(event.candidate);
  }

  Future<void> _onVideoCallHangUp(
    VideoCallHangUp event,
    Emitter<VideoCallState> emit,
  ) async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    await _peerConnection?.close();
    _roomSubscription?.cancel();
    _candidatesSubscription?.cancel();
    emit(const VideoCallState(status: VideoCallStatus.disconnected));
  }

  Future<void> _onVideoCallToggleScreenShare(
    VideoCallToggleScreenShare event,
    Emitter<VideoCallState> emit,
  ) async {
    if (_isScreenSharing) {
      final mediaConstraints = <String, dynamic>{
        'audio': true,
        'video': {
          'facingMode': 'user',
        },
      };
      final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = stream;
      final sender = _peerConnection?.getSenders().firstWhere(
            (sender) => sender.track?.kind == 'video',
          );
      await sender?.replaceTrack(stream.getVideoTracks().first);
    } else {
      final stream = await navigator.mediaDevices.getDisplayMedia({'video': true});
      _localRenderer.srcObject = stream;
      final sender = _peerConnection?.getSenders().firstWhere(
            (sender) => sender.track?.kind == 'video',
          );
      await sender?.replaceTrack(stream.getVideoTracks().first);
    }
    _isScreenSharing = !_isScreenSharing;
  }

  @override
  Future<void> close() {
    _onVideoCallHangUp(VideoCallHangUp(), emit);
    return super.close();
  }
}
