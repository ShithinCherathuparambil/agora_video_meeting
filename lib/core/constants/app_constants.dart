class AppConstants {
  // App Information
  static const String appName = 'VideoMeet';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String meetingsCollection = 'meetings';
  static const String usersCollection = 'users';
  static const String chatCollection = 'chat';
  static const String offerCandidatesCollection = 'offerCandidates';
  static const String answerCandidatesCollection = 'answerCandidates';
  
  // WebRTC Configuration
  static const List<Map<String, String>> iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
  ];
  
  // Meeting Configuration
  static const int maxParticipants = 50;
  static const int meetingCodeLength = 10;
  static const Duration meetingTimeout = Duration(hours: 24);
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  // Media Configuration
  static const Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'mandatory': {
        'minWidth': '640',
        'minHeight': '480',
        'minFrameRate': '30',
      },
      'facingMode': 'user',
      'optional': [],
    }
  };
  
  static const Map<String, dynamic> screenShareConstraints = {
    'audio': false,
    'video': {
      'mandatory': {
        'chromeMediaSource': 'desktop',
        'chromeMediaSourceId': '',
        'maxWidth': '1920',
        'maxHeight': '1080',
        'maxFrameRate': '30',
      }
    }
  };
  
  // Recording Configuration
  static const String recordingMimeType = 'video/webm;codecs=vp9';
  static const int recordingBitrate = 2500000; // 2.5 Mbps
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String authError = 'Authentication failed';
  static const String permissionError = 'Permission denied';
  static const String meetingNotFound = 'Meeting not found';
  static const String meetingFull = 'Meeting is full';
  static const String connectionFailed = 'Failed to connect to meeting';
  
  // Success Messages
  static const String meetingCreated = 'Meeting created successfully';
  static const String meetingJoined = 'Joined meeting successfully';
  static const String recordingStarted = 'Recording started';
  static const String recordingStopped = 'Recording stopped';
  
  // User Roles
  static const String hostRole = 'host';
  static const String participantRole = 'participant';
  
  // Meeting States
  static const String meetingWaiting = 'waiting';
  static const String meetingActive = 'active';
  static const String meetingEnded = 'ended';
  
  // Chat Constants
  static const int maxChatMessageLength = 500;
  static const int chatHistoryLimit = 100;
  
  // File Storage
  static const String recordingsFolder = 'recordings';
  static const String avatarsFolder = 'avatars';
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;
}
