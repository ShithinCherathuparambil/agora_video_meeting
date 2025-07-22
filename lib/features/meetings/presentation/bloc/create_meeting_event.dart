part of 'create_meeting_bloc.dart';

abstract class CreateMeetingEvent extends Equatable {
  const CreateMeetingEvent();

  @override
  List<Object> get props => [];
}

class CreateMeetingRequested extends CreateMeetingEvent {
  final String title;

  const CreateMeetingRequested({required this.title});

  @override
  List<Object> get props => [title];
}
