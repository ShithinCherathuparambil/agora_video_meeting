part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<ChatMessage> messages;

  const ChatState({this.messages = const []});

  @override
  List<Object> get props => [messages];

  ChatState copyWith({
    List<ChatMessage>? messages,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
    );
  }
}
