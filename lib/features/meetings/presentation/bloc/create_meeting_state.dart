part of 'create_meeting_bloc.dart';

abstract class CreateMeetingState extends Equatable {
  const CreateMeetingState();

  @override
  List<Object> get props => [];
}

class CreateMeetingInitial extends CreateMeetingState {}

class CreateMeetingLoading extends CreateMeetingState {}

class CreateMeetingSuccess extends CreateMeetingState {
  final MeetingModel meeting;

  const CreateMeetingSuccess({required this.meeting});

  @override
  List<Object> get props => [meeting];
}

class CreateMeetingFailure extends CreateMeetingState {
  final String error;

  const CreateMeetingFailure({required this.error});

  @override
  List<Object> get props => [error];
}
