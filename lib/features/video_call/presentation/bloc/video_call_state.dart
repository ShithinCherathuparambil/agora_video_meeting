part of 'video_call_bloc.dart';

enum VideoCallStatus { initial, loading, connected, disconnected, error }

class VideoCallState extends Equatable {
  final VideoCallStatus status;
  final String? error;

  const VideoCallState({
    this.status = VideoCallStatus.initial,
    this.error,
  });

  @override
  List<Object?> get props => [status, error];

  VideoCallState copyWith({
    VideoCallStatus? status,
    String? error,
  }) {
    return VideoCallState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
