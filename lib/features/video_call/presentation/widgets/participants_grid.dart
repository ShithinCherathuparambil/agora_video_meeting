import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/webrtc_models.dart';
import '../../../meetings/models/participant_model.dart';
import 'video_renderer_widget.dart';

class ParticipantsGrid extends StatelessWidget {
  final MediaStream? localStream;
  final Map<String, MediaStream> remoteStreams;
  final List<ParticipantModel> participants;
  final Map<String, RTCConnectionState> connectionStates;
  final bool isLocalVideoEnabled;
  final bool isLocalAudioEnabled;
  final String currentUserId;
  final Function(String participantId)? onParticipantTap;

  const ParticipantsGrid({
    super.key,
    this.localStream,
    this.remoteStreams = const {},
    this.participants = const [],
    this.connectionStates = const {},
    this.isLocalVideoEnabled = true,
    this.isLocalAudioEnabled = true,
    required this.currentUserId,
    this.onParticipantTap,
  });

  @override
  Widget build(BuildContext context) {
    final allParticipants = _buildParticipantList();
    final participantCount = allParticipants.length;

    if (participantCount == 0) {
      return _buildEmptyState();
    }

    return _buildGrid(allParticipants, participantCount);
  }

  List<_ParticipantData> _buildParticipantList() {
    final List<_ParticipantData> participantList = [];

    // Add local participant first
    final localParticipant = participants.firstWhere(
      (p) => p.userId == currentUserId,
      orElse: () => ParticipantModel(
        id: '',
        meetingId: '',
        userId: currentUserId,
        displayName: 'You',
        email: '',
        role: ParticipantRole.participant,
        status: ParticipantStatus.joined,
        joinedAt: DateTime.now(),
      ),
    );

    participantList.add(_ParticipantData(
      participant: localParticipant,
      stream: localStream,
      isLocal: true,
      isVideoEnabled: isLocalVideoEnabled,
      isAudioEnabled: isLocalAudioEnabled,
      connectionState: RTCConnectionState.connected,
    ));

    // Add remote participants
    for (final participant in participants) {
      if (participant.userId != currentUserId) {
        final stream = remoteStreams[participant.userId];
        final connectionState = connectionStates[participant.userId] ?? RTCConnectionState.disconnected;
        
        participantList.add(_ParticipantData(
          participant: participant,
          stream: stream,
          isLocal: false,
          isVideoEnabled: participant.isCameraOn,
          isAudioEnabled: !participant.isMuted,
          connectionState: connectionState,
        ));
      }
    }

    return participantList;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 50,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Waiting for participants...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share the meeting link to invite others',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_ParticipantData> participants, int count) {
    if (count == 1) {
      return _buildSingleParticipant(participants.first);
    } else if (count == 2) {
      return _buildTwoParticipants(participants);
    } else if (count <= 4) {
      return _buildFourGrid(participants);
    } else if (count <= 6) {
      return _buildSixGrid(participants);
    } else {
      return _buildScrollableGrid(participants);
    }
  }

  Widget _buildSingleParticipant(_ParticipantData participant) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: VideoRendererWidget(
        stream: participant.stream,
        participantName: participant.participant.displayName,
        isLocal: participant.isLocal,
        isMuted: !participant.isAudioEnabled,
        isVideoEnabled: participant.isVideoEnabled,
        onTap: () => onParticipantTap?.call(participant.participant.userId),
      ),
    );
  }

  Widget _buildTwoParticipants(List<_ParticipantData> participants) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: participants.map((participant) => 
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: VideoRendererWidget(
                stream: participant.stream,
                participantName: participant.participant.displayName,
                isLocal: participant.isLocal,
                isMuted: !participant.isAudioEnabled,
                isVideoEnabled: participant.isVideoEnabled,
                onTap: () => onParticipantTap?.call(participant.participant.userId),
              ),
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildFourGrid(List<_ParticipantData> participants) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: participants.take(2).map((participant) => 
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: VideoRendererWidget(
                      stream: participant.stream,
                      participantName: participant.participant.displayName,
                      isLocal: participant.isLocal,
                      isMuted: !participant.isAudioEnabled,
                      isVideoEnabled: participant.isVideoEnabled,
                      onTap: () => onParticipantTap?.call(participant.participant.userId),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
          if (participants.length > 2)
            Expanded(
              child: Row(
                children: participants.skip(2).take(2).map((participant) => 
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: VideoRendererWidget(
                        stream: participant.stream,
                        participantName: participant.participant.displayName,
                        isLocal: participant.isLocal,
                        isMuted: !participant.isAudioEnabled,
                        isVideoEnabled: participant.isVideoEnabled,
                        onTap: () => onParticipantTap?.call(participant.participant.userId),
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSixGrid(List<_ParticipantData> participants) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: participants.take(3).map((participant) => 
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: VideoRendererWidget(
                      stream: participant.stream,
                      participantName: participant.participant.displayName,
                      isLocal: participant.isLocal,
                      isMuted: !participant.isAudioEnabled,
                      isVideoEnabled: participant.isVideoEnabled,
                      onTap: () => onParticipantTap?.call(participant.participant.userId),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
          if (participants.length > 3)
            Expanded(
              child: Row(
                children: participants.skip(3).take(3).map((participant) => 
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: VideoRendererWidget(
                        stream: participant.stream,
                        participantName: participant.participant.displayName,
                        isLocal: participant.isLocal,
                        isMuted: !participant.isAudioEnabled,
                        isVideoEnabled: participant.isVideoEnabled,
                        onTap: () => onParticipantTap?.call(participant.participant.userId),
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollableGrid(List<_ParticipantData> participants) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 16 / 9,
        ),
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final participant = participants[index];
          return VideoRendererWidget(
            stream: participant.stream,
            participantName: participant.participant.displayName,
            isLocal: participant.isLocal,
            isMuted: !participant.isAudioEnabled,
            isVideoEnabled: participant.isVideoEnabled,
            onTap: () => onParticipantTap?.call(participant.participant.userId),
          );
        },
      ),
    );
  }
}

class _ParticipantData {
  final ParticipantModel participant;
  final MediaStream? stream;
  final bool isLocal;
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final RTCConnectionState connectionState;

  const _ParticipantData({
    required this.participant,
    this.stream,
    required this.isLocal,
    required this.isVideoEnabled,
    required this.isAudioEnabled,
    required this.connectionState,
  });
}
