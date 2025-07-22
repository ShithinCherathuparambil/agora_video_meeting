import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/webrtc_models.dart';
import '../services/webrtc_service.dart';
import 'video_call_event.dart';
import 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final WebRTCService _webrtcService;
  late StreamSubscription _localStreamSubscription;
  late StreamSubscription _remoteStreamsSubscription;
  late StreamSubscription _connectionStatesSubscription;

  VideoCallBloc({WebRTCService? webrtcService})
    : _webrtcService = webrtcService ?? WebRTCService(),
      super(const VideoCallState()) {
    // Set up stream subscriptions
    _localStreamSubscription = _webrtcService.localStream.listen(
      (stream) => add(VideoCallLocalStreamUpdated(stream: stream)),
    );

    _remoteStreamsSubscription = _webrtcService.remoteStreams.listen(
      (streams) => add(VideoCallRemoteStreamsUpdated(streams: streams)),
    );

    _connectionStatesSubscription = _webrtcService.connectionStates.listen(
      (states) => add(VideoCallConnectionStatesUpdated(states: states)),
    );

    // Register event handlers
    on<VideoCallInitialize>(_onInitialize);
    on<VideoCallConnectToPeer>(_onConnectToPeer);
    on<VideoCallDisconnectFromPeer>(_onDisconnectFromPeer);
    on<VideoCallToggleVideo>(_onToggleVideo);
    on<VideoCallToggleAudio>(_onToggleAudio);
    on<VideoCallSwitchCamera>(_onSwitchCamera);
    on<VideoCallLocalStreamUpdated>(_onLocalStreamUpdated);
    on<VideoCallRemoteStreamsUpdated>(_onRemoteStreamsUpdated);
    on<VideoCallConnectionStatesUpdated>(_onConnectionStatesUpdated);
    on<VideoCallEnd>(_onEnd);
    on<VideoCallError>(_onError);
  }

  Future<void> _onInitialize(
    VideoCallInitialize event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: VideoCallStatus.initializing,
          meetingId: event.meetingId,
          userId: event.userId,
        ),
      );

      await _webrtcService.initializeForMeeting(
        meetingId: event.meetingId,
        userId: event.userId,
        constraints: event.constraints,
      );

      emit(
        state.copyWith(
          status: VideoCallStatus.ready,
          isVideoEnabled: event.constraints.video,
          isAudioEnabled: event.constraints.audio,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoCallStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onConnectToPeer(
    VideoCallConnectToPeer event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      emit(state.copyWith(status: VideoCallStatus.connecting));

      await _webrtcService.connectToPeer(event.peerId);

      // Status will be updated via connection state changes
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoCallStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDisconnectFromPeer(
    VideoCallDisconnectFromPeer event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      await _webrtcService.disconnectFromPeer(event.peerId);

      // Update status based on remaining connections
      if (state.connectedPeersCount == 0) {
        emit(state.copyWith(status: VideoCallStatus.ready));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoCallStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleVideo(
    VideoCallToggleVideo event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      await _webrtcService.toggleVideo();
      emit(state.copyWith(isVideoEnabled: _webrtcService.isVideoEnabled));
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoCallStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleAudio(
    VideoCallToggleAudio event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      await _webrtcService.toggleAudio();
      emit(state.copyWith(isAudioEnabled: _webrtcService.isAudioEnabled));
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoCallStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSwitchCamera(
    VideoCallSwitchCamera event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      await _webrtcService.switchCamera();
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoCallStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onLocalStreamUpdated(
    VideoCallLocalStreamUpdated event,
    Emitter<VideoCallState> emit,
  ) {
    emit(state.copyWith(localStream: event.stream));
  }

  void _onRemoteStreamsUpdated(
    VideoCallRemoteStreamsUpdated event,
    Emitter<VideoCallState> emit,
  ) {
    emit(state.copyWith(remoteStreams: event.streams));
  }

  void _onConnectionStatesUpdated(
    VideoCallConnectionStatesUpdated event,
    Emitter<VideoCallState> emit,
  ) {
    emit(state.copyWith(connectionStates: event.states));

    // Update overall status based on connection states
    final hasConnectedPeers = event.states.values.any(
      (state) => state == RTCConnectionState.connected,
    );

    if (hasConnectedPeers && state.status != VideoCallStatus.connected) {
      emit(state.copyWith(status: VideoCallStatus.connected));
    } else if (!hasConnectedPeers &&
        state.status == VideoCallStatus.connected) {
      emit(state.copyWith(status: VideoCallStatus.ready));
    }
  }

  Future<void> _onEnd(VideoCallEnd event, Emitter<VideoCallState> emit) async {
    try {
      await _webrtcService.dispose();
      emit(
        state.copyWith(
          status: VideoCallStatus.disconnected,
          localStream: null,
          remoteStreams: const {},
          connectionStates: const {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoCallStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onError(VideoCallError event, Emitter<VideoCallState> emit) {
    emit(
      state.copyWith(
        status: VideoCallStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _localStreamSubscription.cancel();
    await _remoteStreamsSubscription.cancel();
    await _connectionStatesSubscription.cancel();
    await _webrtcService.dispose();
    return super.close();
  }
}
