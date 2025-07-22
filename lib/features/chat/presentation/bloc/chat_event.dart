part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatMessageSent extends ChatEvent {
  final String meetingId;
  final String senderId;
  final String message;

  const ChatMessageSent({
    required this.meetingId,
    required this.senderId,
    required this.message,
  });

  @override
  List<Object> get props => [meetingId, senderId, message];
}

class ChatMessagesReceived extends ChatEvent {
  final List<ChatMessage> messages;

  const ChatMessagesReceived({required this.messages});

  @override
  List<Object> get props => [messages];
}
