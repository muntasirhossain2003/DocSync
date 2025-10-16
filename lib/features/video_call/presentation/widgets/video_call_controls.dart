// lib/features/video_call/presentation/widgets/video_call_controls.dart
import 'package:flutter/material.dart';
import '../../domain/models/call_state.dart';

class VideoCallControls extends StatelessWidget {
  final VideoCallInfo callInfo;
  final VoidCallback onEndCall;
  final VoidCallback onToggleMicrophone;
  final VoidCallback onToggleCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleSpeaker;
  final bool isMuted;
  final bool isCameraEnabled;
  final bool isSpeakerEnabled;

  const VideoCallControls({
    super.key,
    required this.callInfo,
    required this.onEndCall,
    required this.onToggleMicrophone,
    required this.onToggleCamera,
    required this.onSwitchCamera,
    required this.onToggleSpeaker,
    required this.isMuted,
    required this.isCameraEnabled,
    required this.isSpeakerEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          _buildControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            onPressed: onToggleMicrophone,
            backgroundColor: isMuted
                ? Colors.red
                : Colors.white.withOpacity(0.3),
            iconColor: isMuted ? Colors.white : Colors.white,
          ),

          // Camera toggle
          _buildControlButton(
            icon: isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            onPressed: onToggleCamera,
            backgroundColor: isCameraEnabled
                ? Colors.white.withOpacity(0.3)
                : Colors.red,
            iconColor: Colors.white,
          ),

          // Speaker toggle
          _buildControlButton(
            icon: isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
            onPressed: onToggleSpeaker,
            backgroundColor: isSpeakerEnabled
                ? Colors.white.withOpacity(0.3)
                : Colors.red,
            iconColor: Colors.white,
          ),

          // Switch camera
          _buildControlButton(
            icon: Icons.cameraswitch,
            onPressed: onSwitchCamera,
            backgroundColor: Colors.white.withOpacity(0.3),
            iconColor: Colors.white,
          ),

          // End call
          _buildControlButton(
            icon: Icons.call_end,
            onPressed: onEndCall,
            backgroundColor: Colors.red,
            iconColor: Colors.white,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
    bool isLarge = false,
  }) {
    return Container(
      width: isLarge ? 64 : 56,
      height: isLarge ? 64 : 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: isLarge ? 32 : 28),
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}
