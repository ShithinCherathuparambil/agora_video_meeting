import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AppUtils {
  static const _uuid = Uuid();
  static final _random = Random();

  /// Generate a unique ID
  static String generateId() => _uuid.v4();

  /// Generate a meeting code (10 characters, alphanumeric)
  static String generateMeetingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      10,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Format timestamp to readable string
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  /// Format duration to readable string (e.g., "1h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate meeting code format
  static bool isValidMeetingCode(String code) {
    return RegExp(r'^[A-Z0-9]{10}$').hasMatch(code);
  }

  /// Generate initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
          .toUpperCase();
    }
  }

  /// Get random avatar color
  static int getAvatarColor(String userId) {
    final colors = [
      0xFFFF6B6B, // Red
      0xFF4ECDC4, // Teal
      0xFF45B7D1, // Blue
      0xFF96CEB4, // Green
      0xFFFECA57, // Yellow
      0xFFFF9FF3, // Pink
      0xFF54A0FF, // Light Blue
      0xFF5F27CD, // Purple
    ];

    final hash = userId.hashCode;
    return colors[hash.abs() % colors.length];
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Convert bytes to human readable format
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if platform supports feature
  static bool get isWeb => identical(0, 0.0);

  /// Generate random participant name for testing
  static String generateRandomName() {
    final firstNames = [
      'Alex',
      'Sam',
      'Jordan',
      'Casey',
      'Taylor',
      'Morgan',
      'Riley',
      'Avery',
    ];
    final lastNames = [
      'Smith',
      'Johnson',
      'Brown',
      'Davis',
      'Miller',
      'Wilson',
      'Moore',
      'Taylor',
    ];

    return '${firstNames[_random.nextInt(firstNames.length)]} ${lastNames[_random.nextInt(lastNames.length)]}';
  }

  /// Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(Function() action, Duration delay) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  /// Show snackbar message
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.red : AppTheme.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
