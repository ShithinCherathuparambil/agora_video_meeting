import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gooteam_stream/features/chat/models/chat_message.dart';
import 'package:gooteam_stream/features/chat/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _messagesSubscription;

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatState()) {
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatMessagesReceived>(_onChatMessagesReceived);
  }

  void startListening(String meetingId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepository.getMessages(meetingId).listen((messages) {
      add(ChatMessagesReceived(messages: messages));
    });
  }

  void _onChatMessageSent(ChatMessageSent event, Emitter<ChatState> emit) {
    // TODO: Get user ID and meeting ID
    _chatRepository.sendMessage('', '', event.message);
  }

  void _onChatMessagesReceived(
    ChatMessagesReceived event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(messages: event.messages));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
