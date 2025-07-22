import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../../video_call/bloc/video_call_bloc.dart';
import '../../../video_call/bloc/video_call_event.dart';
import '../../../video_call/presentation/pages/meeting_room_page.dart';
import '../../models/meeting_model.dart';
import '../../models/participant_model.dart';

class JoinMeetingPage extends StatefulWidget {
  const JoinMeetingPage({super.key});

  @override
  State<JoinMeetingPage> createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final _meetingIdController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _meetingIdController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _joinMeeting() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is! AuthAuthenticated) {
          throw Exception('User not authenticated');
        }

        // For demo purposes, create a mock meeting
        final meeting = MeetingModel(
          id: _meetingIdController.text.trim(),
          title: 'Demo Meeting',
          hostId: authState.user.id,
          hostName: authState.user.displayName,
          type: MeetingType.instant,
          status: MeetingStatus.active,
          createdAt: DateTime.now(),
        );

        final participants = [
          ParticipantModel(
            id: '1',
            meetingId: meeting.id,
            userId: authState.user.id,
            displayName: _displayNameController.text.trim(),
            email: authState.user.email,
            role: ParticipantRole.host,
            status: ParticipantStatus.joined,
            joinedAt: DateTime.now(),
          ),
        ];

        // Initialize video call
        context.read<VideoCallBloc>().add(VideoCallInitialize(
          meetingId: meeting.id,
          userId: authState.user.id,
        ));

        // Navigate to meeting room
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MeetingRoomPage(
                meetingId: meeting.id,
                meeting: meeting,
                participants: participants,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to join meeting: ${e.toString()}'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validateMeetingId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a meeting ID';
    }
    if (value.length < 3) {
      return 'Meeting ID must be at least 3 characters';
    }
    return null;
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your display name';
    }
    if (value.length < 2) {
      return 'Display name must be at least 2 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Join Meeting'),
        backgroundColor: AppTheme.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.video_call,
                          size: 50,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Join a Meeting',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter the meeting ID to join the video call',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Meeting ID Field
                CustomTextField(
                  label: 'Meeting ID',
                  hint: 'Enter meeting ID or code',
                  controller: _meetingIdController,
                  validator: _validateMeetingId,
                  prefixIcon: const Icon(Icons.meeting_room, color: AppTheme.mediumGray),
                ),
                
                const SizedBox(height: 24),
                
                // Display Name Field
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      _displayNameController.text = state.user.displayName;
                    }
                    return CustomTextField(
                      label: 'Display Name',
                      hint: 'How others will see you',
                      controller: _displayNameController,
                      validator: _validateDisplayName,
                      prefixIcon: const Icon(Icons.person, color: AppTheme.mediumGray),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Join Button
                CustomButton(
                  text: 'Join Meeting',
                  onPressed: _isLoading ? null : _joinMeeting,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Create Meeting',
                        onPressed: () {
                          // TODO: Navigate to create meeting
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Create Meeting - Coming Soon!')),
                          );
                        },
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Schedule',
                        onPressed: () {
                          // TODO: Navigate to schedule meeting
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Schedule Meeting - Coming Soon!')),
                          );
                        },
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.darkGray.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tips',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Make sure you have a stable internet connection\n'
                        '• Allow camera and microphone permissions\n'
                        '• Use headphones for better audio quality\n'
                        '• Find a quiet, well-lit space',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGray.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
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
