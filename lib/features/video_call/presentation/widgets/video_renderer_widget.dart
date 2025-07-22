import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/theme/app_theme.dart';

class VideoRendererWidget extends StatefulWidget {
  final MediaStream? stream;
  final String? participantName;
  final bool isLocal;
  final bool isMuted;
  final bool isVideoEnabled;
  final VoidCallback? onTap;
  final bool showControls;
  final Widget? overlayWidget;

  const VideoRendererWidget({
    super.key,
    this.stream,
    this.participantName,
    this.isLocal = false,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.onTap,
    this.showControls = true,
    this.overlayWidget,
  });

  @override
  State<VideoRendererWidget> createState() => _VideoRendererWidgetState();
}

class _VideoRendererWidgetState extends State<VideoRendererWidget> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
  }

  @override
  void didUpdateWidget(VideoRendererWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _updateStream();
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderer() async {
    try {
      await _renderer.initialize();
      setState(() {
        _isInitialized = true;
      });
      _updateStream();
    } catch (e) {
      print('Failed to initialize video renderer: $e');
    }
  }

  void _updateStream() {
    if (_isInitialized && widget.stream != null) {
      _renderer.srcObject = widget.stream;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isLocal ? AppTheme.primaryYellow : AppTheme.lightGray,
            width: widget.isLocal ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Video or placeholder
              if (_isInitialized && widget.stream != null && widget.isVideoEnabled)
                Positioned.fill(
                  child: RTCVideoView(
                    _renderer,
                    mirror: widget.isLocal,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                )
              else
                _buildVideoPlaceholder(),

              // Overlay widget
              if (widget.overlayWidget != null)
                Positioned.fill(child: widget.overlayWidget!),

              // Controls overlay
              if (widget.showControls) _buildControlsOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: AppTheme.mediumGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryYellow,
              child: Text(
                widget.participantName?.isNotEmpty == true
                    ? widget.participantName![0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
            if (widget.participantName != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.participantName!,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (!widget.isVideoEnabled) ...[
              const SizedBox(height: 8),
              const Icon(
                Icons.videocam_off,
                color: AppTheme.white,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Row(
        children: [
          // Participant name
          if (widget.participantName != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.darkGray.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.participantName!,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          const SizedBox(width: 8),

          // Status indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isMuted)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.mic_off,
                    color: AppTheme.white,
                    size: 16,
                  ),
                ),
              
              if (!widget.isVideoEnabled) ...[
                if (widget.isMuted) const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.videocam_off,
                    color: AppTheme.white,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
