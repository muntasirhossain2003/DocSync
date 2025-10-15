// lib/features/video_call/presentation/widgets/video_call_status.dart
import 'package:flutter/material.dart';

import '../../domain/models/call_state.dart';

class VideoCallStatus extends StatelessWidget {
  final CallState status;

  const VideoCallStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              _getStatusMessage(status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(CallState status) {
    switch (status) {
      case CallState.connecting:
        return 'Connecting to call...';
      case CallState.reconnecting:
        return 'Reconnecting...';
      default:
        return 'Please wait...';
    }
  }
}
