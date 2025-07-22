import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gooteam_stream/features/meetings/models/meeting_model.dart';
import 'package:gooteam_stream/features/meetings/repositories/meeting_repository.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/domain/entities/user_entity.dart';

part 'create_meeting_event.dart';
part 'create_meeting_state.dart';

class CreateMeetingBloc extends Bloc<CreateMeetingEvent, CreateMeetingState> {
  final MeetingRepository _meetingRepository;
  final UserEntity _user;

  CreateMeetingBloc({
    required MeetingRepository meetingRepository,
    required UserEntity user,
  })  : _meetingRepository = meetingRepository,
        _user = user,
        super(CreateMeetingInitial()) {
    on<CreateMeetingRequested>(_onCreateMeetingRequested);
  }

  Future<void> _onCreateMeetingRequested(
    CreateMeetingRequested event,
    Emitter<CreateMeetingState> emit,
  ) async {
    emit(CreateMeetingLoading());
    try {
      final meeting = MeetingModel(
        id: const Uuid().v4(),
        title: event.title,
        hostId: _user.id,
        hostName: _user.displayName,
        type: MeetingType.instant,
        status: MeetingStatus.scheduled,
        createdAt: DateTime.now(),
      );
      await _meetingRepository.createMeeting(meeting);
      emit(CreateMeetingSuccess(meeting: meeting));
    } catch (e) {
      emit(CreateMeetingFailure(error: e.toString()));
    }
  }
}
