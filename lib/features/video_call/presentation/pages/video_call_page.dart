// lib/features/video_call/presentation/pages/video_call_page.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/agora_config.dart';
import '../../domain/models/call_state.dart';
import '../providers/video_call_provider.dart';
import '../widgets/video_call_controls.dart';
import '../widgets/video_call_status.dart';

class VideoCallPage extends ConsumerStatefulWidget {
  final VideoCallInfo callInfo;

  const VideoCallPage({super.key, required this.callInfo});

  @override
  ConsumerState<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends ConsumerState<VideoCallPage> {
  @override
  void initState() {
    super.initState();
    // Initialize call when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(videoCallControllerProvider(widget.callInfo).notifier)
          .initializeCall();
    });
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(videoCallControllerProvider(widget.callInfo));
    final controller = ref.watch(
      videoCallControllerProvider(widget.callInfo).notifier,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen)
            _buildRemoteVideo(controller, callState),

            // Local video (small preview)
            Positioned(top: 40, right: 16, child: _buildLocalVideo(controller)),

            // Top bar with doctor info
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context, callState),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoCallControls(
                callInfo: widget.callInfo,
                onEndCall: () async {
                  await controller.endCall();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                onToggleMicrophone: () => controller.toggleMicrophone(),
                onToggleCamera: () => controller.toggleCamera(),
                onSwitchCamera: () => controller.switchCamera(),
                isMuted: controller.isMuted,
                isCameraEnabled: controller.isCameraEnabled,
              ),
            ),

            // Connection status overlay
            if (callState == CallState.connecting ||
                callState == CallState.reconnecting)
              VideoCallStatus(status: callState),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideo(VideoCallController controller, CallState state) {
    if (controller.remoteUid == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              backgroundImage: widget.callInfo.doctorProfileUrl != null
                  ? NetworkImage(widget.callInfo.doctorProfileUrl!)
                  : null,
              child: widget.callInfo.doctorProfileUrl == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              widget.callInfo.doctorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state == CallState.connected
                  ? 'Waiting for doctor to join...'
                  : 'Connecting...',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return controller.engine != null
        ? AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: controller.engine!,
              canvas: VideoCanvas(uid: controller.remoteUid),
              connection: RtcConnection(channelId: AgoraConfig.channelName),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildLocalVideo(VideoCallController controller) {
    if (!controller.isCameraEnabled) {
      return Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white, size: 40),
        ),
      );
    }

    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: controller.engine != null
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: controller.engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            : Container(color: Colors.black),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CallState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final controller = ref.read(
                videoCallControllerProvider(widget.callInfo).notifier,
              );
              await controller.endCall();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.callInfo.doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getStatusText(state),
                  style: TextStyle(color: _getStatusColor(state), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(CallState state) {
    switch (state) {
      case CallState.connecting:
        return 'Connecting...';
      case CallState.connected:
        return 'Connected';
      case CallState.reconnecting:
        return 'Reconnecting...';
      case CallState.disconnected:
        return 'Disconnected';
      case CallState.error:
        return 'Connection Error';
      default:
        return '';
    }
  }

  Color _getStatusColor(CallState state) {
    switch (state) {
      case CallState.connected:
        return Colors.green;
      case CallState.error:
        return Colors.red;
      case CallState.reconnecting:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
