class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class MeetingException implements Exception {
  final String message;
  const MeetingException(this.message);
}

class WebRTCException implements Exception {
  final String message;
  const WebRTCException(this.message);
}

class ChatException implements Exception {
  final String message;
  const ChatException(this.message);
}

class RecordingException implements Exception {
  final String message;
  const RecordingException(this.message);
}
