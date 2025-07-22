import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MeetingControls extends StatelessWidget {
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final bool isChatVisible;
  final bool isScreenSharing;
  final VoidCallback? onToggleVideo;
  final VoidCallback? onToggleAudio;
  final VoidCallback? onSwitchCamera;
  final VoidCallback? onToggleChat;
  final VoidCallback? onToggleScreenShare;
  final VoidCallback? onShowParticipants;
  final VoidCallback? onShowSettings;
  final VoidCallback? onEndCall;
  final int participantCount;
  final int unreadMessageCount;

  const MeetingControls({
    super.key,
    required this.isVideoEnabled,
    required this.isAudioEnabled,
    this.isChatVisible = false,
    this.isScreenSharing = false,
    this.onToggleVideo,
    this.onToggleAudio,
    this.onSwitchCamera,
    this.onToggleChat,
    this.onToggleScreenShare,
    this.onShowParticipants,
    this.onShowSettings,
    this.onEndCall,
    this.participantCount = 0,
    this.unreadMessageCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkGray.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Video toggle
            _buildControlButton(
              icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              isActive: isVideoEnabled,
              onTap: onToggleVideo,
              tooltip: isVideoEnabled ? 'Turn off camera' : 'Turn on camera',
            ),

            // Audio toggle
            _buildControlButton(
              icon: isAudioEnabled ? Icons.mic : Icons.mic_off,
              isActive: isAudioEnabled,
              onTap: onToggleAudio,
              tooltip: isAudioEnabled ? 'Mute' : 'Unmute',
            ),

            // Switch camera
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              isActive: true,
              onTap: onSwitchCamera,
              tooltip: 'Switch camera',
              isSecondary: true,
            ),

            // Screen share
            _buildControlButton(
              icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
              isActive: isScreenSharing,
              onTap: onToggleScreenShare,
              tooltip: isScreenSharing ? 'Stop sharing' : 'Share screen',
              isSecondary: true,
            ),

            // Participants
            _buildControlButton(
              icon: Icons.people,
              isActive: true,
              onTap: onShowParticipants,
              tooltip: 'Participants',
              badge: participantCount > 0 ? participantCount.toString() : null,
              isSecondary: true,
            ),

            // Chat
            _buildControlButton(
              icon: Icons.chat_bubble_outline,
              isActive: isChatVisible,
              onTap: onToggleChat,
              tooltip: 'Chat',
              badge: unreadMessageCount > 0 ? unreadMessageCount.toString() : null,
              isSecondary: true,
            ),

            // Settings
            _buildControlButton(
              icon: Icons.settings,
              isActive: true,
              onTap: onShowSettings,
              tooltip: 'Settings',
              isSecondary: true,
            ),

            // End call
            _buildControlButton(
              icon: Icons.call_end,
              isActive: true,
              onTap: onEndCall,
              tooltip: 'End call',
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    VoidCallback? onTap,
    String? tooltip,
    String? badge,
    bool isSecondary = false,
    bool isDestructive = false,
  }) {
    Color backgroundColor;
    Color iconColor;

    if (isDestructive) {
      backgroundColor = AppTheme.red;
      iconColor = AppTheme.white;
    } else if (isSecondary) {
      backgroundColor = AppTheme.mediumGray.withValues(alpha: 0.3);
      iconColor = AppTheme.white;
    } else {
      backgroundColor = isActive ? AppTheme.primaryYellow : AppTheme.red;
      iconColor = isActive ? AppTheme.darkGray : AppTheme.white;
    }

    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
    );

    Widget result = button;

    // Add badge if provided
    if (badge != null) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.white, width: 1),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                badge,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    // Add tooltip if provided
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip,
        child: result,
      );
    }

    return result;
  }
}
