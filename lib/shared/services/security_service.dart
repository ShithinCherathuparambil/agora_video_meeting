import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final Logger _logger = Logger();

  /// Validate if user can create a meeting
  bool canCreateMeeting(UserEntity? user) {
    if (user == null) {
      _logger.w('User not authenticated - cannot create meeting');
      return false;
    }

    if (!user.isEmailVerified) {
      _logger.w('User email not verified - cannot create meeting');
      return false;
    }

    return true;
  }

  /// Validate if user can join a meeting
  bool canJoinMeeting(UserEntity? user) {
    if (user == null) {
      _logger.w('User not authenticated - cannot join meeting');
      return false;
    }

    return true;
  }

  /// Validate if user is the host of a meeting
  bool isHost(UserEntity? user, String hostId) {
    if (user == null) return false;
    return user.id == hostId;
  }

  /// Validate if user can perform host actions (kick users, end meeting, etc.)
  bool canPerformHostActions(UserEntity? user, String hostId) {
    return isHost(user, hostId);
  }

  /// Validate if user can send chat messages
  bool canSendChatMessage(UserEntity? user, String message) {
    if (user == null) {
      _logger.w('User not authenticated - cannot send chat message');
      return false;
    }

    if (message.trim().isEmpty) {
      _logger.w('Empty message - cannot send');
      return false;
    }

    if (message.length > AppConstants.maxChatMessageLength) {
      _logger.w('Message too long - cannot send');
      return false;
    }

    // Check for spam or inappropriate content (basic validation)
    if (_containsSpam(message)) {
      _logger.w('Message contains spam - cannot send');
      return false;
    }

    return true;
  }

  /// Validate if user can start recording
  bool canStartRecording(UserEntity? user, String hostId) {
    return canPerformHostActions(user, hostId);
  }

  /// Validate if user can share screen
  bool canShareScreen(UserEntity? user) {
    if (user == null) {
      _logger.w('User not authenticated - cannot share screen');
      return false;
    }

    return true;
  }

  /// Validate meeting code format
  bool isValidMeetingCode(String code) {
    if (code.isEmpty) return false;

    // Meeting code should be alphanumeric and of specific length
    final regex = RegExp(
      r'^[A-Z0-9]{' + AppConstants.meetingCodeLength.toString() + r'}$',
    );
    return regex.hasMatch(code);
  }

  /// Sanitize user input to prevent XSS and injection attacks
  String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .trim();
  }

  /// Validate user display name
  bool isValidDisplayName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.length < AppConstants.minUsernameLength) return false;
    if (name.length > AppConstants.maxUsernameLength) return false;

    // Check for inappropriate content
    if (_containsInappropriateContent(name)) return false;

    return true;
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Validate password strength
  PasswordValidationResult validatePassword(String password) {
    final errors = <String>[];

    if (password.length < AppConstants.minPasswordLength) {
      errors.add(
        'Password must be at least ${AppConstants.minPasswordLength} characters long',
      );
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Password must contain at least one special character');
    }

    return PasswordValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Check for rate limiting (basic implementation)
  bool isRateLimited(String userId, String action) {
    // In a real implementation, this would check against a rate limiting service
    // For now, return false (no rate limiting)
    return false;
  }

  /// Log security events
  void logSecurityEvent(
    String event,
    String userId,
    Map<String, dynamic>? metadata,
  ) {
    final metadataStr = metadata != null ? ' - Metadata: $metadata' : '';
    _logger.i('Security Event: $event for user $userId$metadataStr');
  }

  /// Basic spam detection
  bool _containsSpam(String message) {
    final spamKeywords = [
      'spam',
      'advertisement',
      'buy now',
      'click here',
      'free money',
      'get rich quick',
      'limited time offer',
    ];

    final lowerMessage = message.toLowerCase();
    return spamKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Basic inappropriate content detection
  bool _containsInappropriateContent(String content) {
    final inappropriateWords = [
      // Add inappropriate words here
      'badword1', 'badword2', // placeholder
    ];

    final lowerContent = content.toLowerCase();
    return inappropriateWords.any((word) => lowerContent.contains(word));
  }

  /// Generate secure meeting ID
  String generateSecureMeetingId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';

    for (int i = 0; i < AppConstants.meetingCodeLength; i++) {
      result += chars[(random + i) % chars.length];
    }

    return result;
  }
}

class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;

  PasswordValidationResult({required this.isValid, required this.errors});
}
