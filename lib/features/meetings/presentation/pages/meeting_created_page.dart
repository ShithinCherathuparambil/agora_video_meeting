import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gooteam_stream/features/auth/bloc/auth_bloc.dart';
import 'package:gooteam_stream/features/auth/bloc/auth_state.dart';
import 'package:gooteam_stream/features/meetings/models/meeting_model.dart';
import 'package:gooteam_stream/features/video_call/bloc/video_call_bloc.dart';
import 'package:gooteam_stream/features/video_call/bloc/video_call_event.dart';
import 'package:gooteam_stream/features/video_call/presentation/pages/meeting_room_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/participant_model.dart';

class MeetingCreatedPage extends StatelessWidget {
  final MeetingModel meeting;

  const MeetingCreatedPage({
    super.key,
    required this.meeting,
  });

  void _joinMeeting(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not authenticated.')),
      );
      return;
    }

    context.read<VideoCallBloc>().add(VideoCallInitialize(
          meetingId: meeting.id,
          userId: authState.user.id,
        ));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeetingRoomPage(
          meetingId: meeting.id,
          meeting: meeting,
          participants: [
            ParticipantModel(
              id: '1',
              meetingId: meeting.id,
              userId: authState.user.id,
              displayName: authState.user.displayName,
              email: authState.user.email,
              role: ParticipantRole.host,
              status: ParticipantStatus.joined,
              joinedAt: DateTime.now(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Meeting Created'),
        backgroundColor: AppTheme.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppTheme.primaryGreen,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your meeting is ready!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Share this code with others to join:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.mediumGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: meeting.meetingCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Meeting code copied to clipboard!'),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryYellow,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          meeting.meetingCode,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.copy_all_rounded,
                          color: AppTheme.mediumGray,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => _joinMeeting(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Join Meeting Now'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Create another meeting',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
