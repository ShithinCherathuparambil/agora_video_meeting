import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gooteam_stream/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:gooteam_stream/features/chat/presentation/widgets/chat_view.dart';
import 'package:gooteam_stream/features/meetings/models/meeting_model.dart';
import 'package:gooteam_stream/features/meetings/models/participant_model.dart';
import 'package:gooteam_stream/features/video_call/presentation/bloc/video_call_bloc.dart';

class MeetingRoomPage extends StatelessWidget {
  final String meetingId;
  final MeetingModel meeting;
  final List<ParticipantModel> participants;

  const MeetingRoomPage({
    super.key,
    required this.meetingId,
    required this.meeting,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        final userId = authState.status == AuthStatus.authenticated ? authState.user!.uid : '';
        return VideoCallBloc(signalingService: context.read())
          ..add(VideoCallInitialize(meetingId: meetingId, userId: userId));
      },
        ),
        BlocProvider(
          create: (context) => ChatBloc(chatRepository: context.read())..startListening(meetingId),
        ),
      ],
      child: const MeetingRoomView(),
    );
  }
}

class MeetingRoomView extends StatelessWidget {
  const MeetingRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => ChatView(meetingId: meetingId),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.screen_share),
            onPressed: () {
              context.read<VideoCallBloc>().add(VideoCallToggleScreenShare());
            },
          ),
          IconButton(
            icon: const Icon(Icons.fiber_manual_record),
            onPressed: () {
              context.read<VideoCallBloc>().add(VideoCallToggleRecording());
            },
          ),
          IconButton(
            icon: const Icon(Icons.wallpaper),
            onPressed: () {
              context.read<VideoCallBloc>().add(VideoCallToggleVirtualBackground());
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () {
              context.read<VideoCallBloc>().add(VideoCallHangUp());
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: BlocBuilder<VideoCallBloc, VideoCallState>(
        builder: (context, state) {
          if (state.status == VideoCallStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              Positioned.fill(
                child: RTCVideoView(context.read<VideoCallBloc>().remoteRenderer),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: RTCVideoView(context.read<VideoCallBloc>().localRenderer),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
