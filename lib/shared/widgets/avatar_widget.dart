import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: borderColor ?? AppTheme.primaryYellow,
                  width: borderWidth,
                )
              : null,
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final initials = AppUtils.getInitials(name);
    final backgroundColor = Color(AppUtils.getAvatarColor(name));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppTheme.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ParticipantAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool isMuted;
  final bool isHost;
  final bool isActiveSpeaker;
  final double size;
  final VoidCallback? onTap;

  const ParticipantAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.isMuted = false,
    this.isHost = false,
    this.isActiveSpeaker = false,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AvatarWidget(
          imageUrl: imageUrl,
          name: name,
          size: size,
          showBorder: isActiveSpeaker,
          borderColor: AppTheme.activeSpeakerBorder,
          borderWidth: 3,
          onTap: onTap,
        ),
        
        // Host indicator
        if (isHost)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: const BoxDecoration(
                color: AppTheme.primaryYellow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                size: size * 0.2,
                color: AppTheme.darkGray,
              ),
            ),
          ),
        
        // Mute indicator
        if (isMuted)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: const BoxDecoration(
                color: AppTheme.mutedIndicator,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_off,
                size: size * 0.2,
                color: AppTheme.white,
              ),
            ),
          ),
      ],
    );
  }
}
