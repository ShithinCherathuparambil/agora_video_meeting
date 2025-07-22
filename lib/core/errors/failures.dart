import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Invalid email or password');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('User not found');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('Password is too weak');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Email is already in use');
}

// Meeting failures
class MeetingFailure extends Failure {
  const MeetingFailure(super.message);
}

class MeetingNotFoundFailure extends MeetingFailure {
  const MeetingNotFoundFailure() : super('Meeting not found');
}

class MeetingFullFailure extends MeetingFailure {
  const MeetingFullFailure() : super('Meeting is full');
}

class MeetingEndedFailure extends MeetingFailure {
  const MeetingEndedFailure() : super('Meeting has ended');
}

class UnauthorizedMeetingFailure extends MeetingFailure {
  const UnauthorizedMeetingFailure() : super('You are not authorized to join this meeting');
}

// WebRTC failures
class WebRTCFailure extends Failure {
  const WebRTCFailure(super.message);
}

class MediaPermissionFailure extends WebRTCFailure {
  const MediaPermissionFailure() : super('Camera or microphone permission denied');
}

class ConnectionFailure extends WebRTCFailure {
  const ConnectionFailure() : super('Failed to establish connection');
}

class MediaDeviceFailure extends WebRTCFailure {
  const MediaDeviceFailure() : super('Media device not available');
}

// Chat failures
class ChatFailure extends Failure {
  const ChatFailure(super.message);
}

class MessageTooLongFailure extends ChatFailure {
  const MessageTooLongFailure() : super('Message is too long');
}

// Recording failures
class RecordingFailure extends Failure {
  const RecordingFailure(super.message);
}

class RecordingNotSupportedFailure extends RecordingFailure {
  const RecordingNotSupportedFailure() : super('Recording is not supported on this platform');
}

class StorageFailure extends RecordingFailure {
  const StorageFailure() : super('Failed to save recording');
}
