import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gooteam_stream/features/auth/bloc/auth_bloc.dart';
import 'package:gooteam_stream/features/auth/bloc/auth_state.dart';
import 'package:gooteam_stream/features/auth/presentation/widgets/custom_button.dart';
import 'package:gooteam_stream/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:gooteam_stream/features/meetings/presentation/bloc/create_meeting_bloc.dart';
import 'package:gooteam_stream/features/meetings/presentation/pages/meeting_created_page.dart';
import 'package:gooteam_stream/features/meetings/repositories/meeting_repository.dart';
import '../../../../core/theme/app_theme.dart';

class CreateMeetingPage extends StatelessWidget {
  const CreateMeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('You must be logged in to create a meeting.'),
        ),
      );
    }

    return BlocProvider(
      create: (context) => CreateMeetingBloc(
        meetingRepository: context.read<MeetingRepository>(),
        user: authState.user,
      ),
      child: const CreateMeetingView(),
    );
  }
}

class CreateMeetingView extends StatefulWidget {
  const CreateMeetingView({super.key});

  @override
  State<CreateMeetingView> createState() => _CreateMeetingViewState();
}

class _CreateMeetingViewState extends State<CreateMeetingView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _createMeeting() {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<CreateMeetingBloc>()
          .add(CreateMeetingRequested(title: _titleController.text));
    }
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a meeting title';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateMeetingBloc, CreateMeetingState>(
      listener: (context, state) {
        if (state is CreateMeetingSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MeetingCreatedPage(meeting: state.meeting),
            ),
          );
        } else if (state is CreateMeetingFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: const Text('Create Meeting'),
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
                            Icons.add_to_photos,
                            size: 50,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Create a New Meeting',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter a title for your meeting',
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

                  // Title Field
                  CustomTextField(
                    label: 'Meeting Title',
                    hint: 'Enter meeting title',
                    controller: _titleController,
                    validator: _validateTitle,
                    prefixIcon: const Icon(Icons.title, color: AppTheme.mediumGray),
                  ),

                  const SizedBox(height: 32),

                  // Create Button
                  BlocBuilder<CreateMeetingBloc, CreateMeetingState>(
                    builder: (context, state) {
                      final isLoading = state is CreateMeetingLoading;
                      return CustomButton(
                        text: 'Create Meeting',
                        onPressed: isLoading ? null : _createMeeting,
                        isLoading: isLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
