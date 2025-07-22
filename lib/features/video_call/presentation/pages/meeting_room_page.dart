import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../meetings/models/meeting_model.dart';
import '../../../meetings/models/participant_model.dart';
import '../../bloc/video_call_bloc.dart';
import '../../bloc/video_call_event.dart';
import '../../bloc/video_call_state.dart';
import '../widgets/participants_grid.dart';
import '../widgets/meeting_controls.dart';

class MeetingRoomPage extends StatefulWidget {
  final String meetingId;
  final MeetingModel meeting;
  final List<ParticipantModel> participants;

  const MeetingRoomPage({
    super.key,
    required this.meetingId,
    required this.meeting,
    this.participants = const [],
  });

  @override
  State<MeetingRoomPage> createState() => _MeetingRoomPageState();
}

class _MeetingRoomPageState extends State<MeetingRoomPage> {
  bool _isChatVisible = false;
  bool _isParticipantsVisible = false;
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // Set landscape orientation for better video experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Meeting'),
        content: const Text('Are you sure you want to leave this meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endCall();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _endCall() {
    context.read<VideoCallBloc>().add(const VideoCallEnd());
    context.go('/home');
  }

  void _toggleChat() {
    setState(() {
      _isChatVisible = !_isChatVisible;
      if (_isChatVisible) {
        _unreadMessageCount = 0;
      }
    });
  }

  void _toggleParticipants() {
    setState(() {
      _isParticipantsVisible = !_isParticipantsVisible;
    });
  }

  void _showSettings() {
    // TODO: Implement settings modal
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings - Coming Soon!')));
  }

  void _toggleScreenShare() {
    // TODO: Implement screen sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screen Share - Coming Soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      body: BlocConsumer<VideoCallBloc, VideoCallState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: AppTheme.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Main content area
                Expanded(
                  child: Row(
                    children: [
                      // Video area
                      Expanded(
                        flex: _isChatVisible || _isParticipantsVisible ? 3 : 1,
                        child: _buildVideoArea(state),
                      ),

                      // Side panel (chat or participants)
                      if (_isChatVisible || _isParticipantsVisible)
                        Container(
                          width: 300,
                          decoration: const BoxDecoration(
                            color: AppTheme.white,
                            border: Border(
                              left: BorderSide(color: AppTheme.lightGray),
                            ),
                          ),
                          child: _isChatVisible
                              ? _buildChatPanel()
                              : _buildParticipantsPanel(),
                        ),
                    ],
                  ),
                ),

                // Controls
                _buildControls(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.lightGray)),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: _showExitConfirmation,
            icon: const Icon(Icons.arrow_back, color: AppTheme.darkGray),
          ),

          const SizedBox(width: 8),

          // Meeting info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.meeting.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Meeting ID: ${widget.meeting.meetingCode}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),

          // Meeting duration
          BlocBuilder<VideoCallBloc, VideoCallState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightYellow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: state.isConnected
                            ? AppTheme.green
                            : AppTheme.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.isConnected ? 'Connected' : 'Connecting...',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea(VideoCallState state) {
    return ParticipantsGrid(
      localStream: state.localStream,
      remoteStreams: state.remoteStreams,
      participants: widget.participants,
      connectionStates: state.connectionStates,
      isLocalVideoEnabled: state.isVideoEnabled,
      isLocalAudioEnabled: state.isAudioEnabled,
      currentUserId: state.userId ?? '',
      onParticipantTap: (participantId) {
        // TODO: Implement participant actions (pin, spotlight, etc.)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Participant tapped: $participantId')),
        );
      },
    );
  }

  Widget _buildControls(VideoCallState state) {
    return MeetingControls(
      isVideoEnabled: state.isVideoEnabled,
      isAudioEnabled: state.isAudioEnabled,
      isChatVisible: _isChatVisible,
      participantCount: widget.participants.length,
      unreadMessageCount: _unreadMessageCount,
      onToggleVideo: () {
        context.read<VideoCallBloc>().add(const VideoCallToggleVideo());
      },
      onToggleAudio: () {
        context.read<VideoCallBloc>().add(const VideoCallToggleAudio());
      },
      onSwitchCamera: () {
        context.read<VideoCallBloc>().add(const VideoCallSwitchCamera());
      },
      onToggleChat: _toggleChat,
      onToggleScreenShare: _toggleScreenShare,
      onShowParticipants: _toggleParticipants,
      onShowSettings: _showSettings,
      onEndCall: _showExitConfirmation,
    );
  }

  Widget _buildChatPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chat header
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, color: AppTheme.darkGray),
              const SizedBox(width: 8),
              const Text(
                'Chat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _isChatVisible = false),
                icon: const Icon(Icons.close, color: AppTheme.mediumGray),
              ),
            ],
          ),

          const Divider(),

          // Chat messages area
          const Expanded(
            child: Center(
              child: Text(
                'Chat functionality coming soon!',
                style: TextStyle(color: AppTheme.mediumGray, fontSize: 16),
              ),
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(Icons.send, color: AppTheme.primaryYellow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Participants header
          Row(
            children: [
              const Icon(Icons.people, color: AppTheme.darkGray),
              const SizedBox(width: 8),
              Text(
                'Participants (${widget.participants.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _isParticipantsVisible = false),
                icon: const Icon(Icons.close, color: AppTheme.mediumGray),
              ),
            ],
          ),

          const Divider(),

          // Participants list
          Expanded(
            child: ListView.builder(
              itemCount: widget.participants.length,
              itemBuilder: (context, index) {
                final participant = widget.participants[index];
                final isCurrentUser =
                    participant.userId == widget.meeting.hostId;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryYellow,
                    child: Text(
                      participant.displayName.isNotEmpty
                          ? participant.displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    participant.displayName + (isCurrentUser ? ' (You)' : ''),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(participant.role.name.toUpperCase()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (participant.isMuted)
                        const Icon(
                          Icons.mic_off,
                          color: AppTheme.red,
                          size: 16,
                        ),
                      if (!participant.isCameraOn)
                        const Icon(
                          Icons.videocam_off,
                          color: AppTheme.red,
                          size: 16,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
