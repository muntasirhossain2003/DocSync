// lib/features/video_call/example/video_call_example.dart
// This file demonstrates how to use the video call feature

import 'package:flutter/material.dart';

import '../domain/models/call_state.dart';
import '../presentation/pages/video_call_page.dart';

/// Example 1: Starting a video call from a consultation
void startVideoCallFromConsultation({
  required BuildContext context,
  required String consultationId,
  required String doctorId,
  required String doctorName,
  String? doctorProfileUrl,
  required DateTime scheduledTime,
}) {
  // Create video call info
  final callInfo = VideoCallInfo(
    consultationId: consultationId,
    doctorId: doctorId,
    doctorName: doctorName,
    doctorProfileUrl: doctorProfileUrl,
    patientId: '', // This will be filled from auth in VideoCallPage
    patientName: '', // This will be filled from auth in VideoCallPage
    scheduledTime: scheduledTime,
  );

  // Navigate to video call page
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => VideoCallPage(callInfo: callInfo)),
  );
}

/// Example 2: Starting an instant call with a doctor
void startInstantCall({
  required BuildContext context,
  required String doctorId,
  required String doctorName,
  String? doctorProfileUrl,
}) {
  // Create video call info for instant call
  final callInfo = VideoCallInfo(
    consultationId: 'instant_${DateTime.now().millisecondsSinceEpoch}',
    doctorId: doctorId,
    doctorName: doctorName,
    doctorProfileUrl: doctorProfileUrl,
    patientId: '', // This will be filled from auth in VideoCallPage
    patientName: '', // This will be filled from auth in VideoCallPage
    scheduledTime: DateTime.now(),
  );

  // Navigate to video call page
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => VideoCallPage(callInfo: callInfo)),
  );
}

/// Example 3: Complete widget showing how to integrate video call button
class ExampleVideoCallButton extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String? doctorProfileUrl;
  final bool isDoctorAvailable;

  const ExampleVideoCallButton({
    super.key,
    required this.doctorId,
    required this.doctorName,
    this.doctorProfileUrl,
    required this.isDoctorAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isDoctorAvailable
          ? () {
              startInstantCall(
                context: context,
                doctorId: doctorId,
                doctorName: doctorName,
                doctorProfileUrl: doctorProfileUrl,
              );
            }
          : null,
      icon: const Icon(Icons.video_call),
      label: const Text('Start Video Call'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Example 4: Scheduled call button with time validation
class ExampleScheduledCallButton extends StatelessWidget {
  final String consultationId;
  final String doctorId;
  final String doctorName;
  final String? doctorProfileUrl;
  final DateTime scheduledTime;

  const ExampleScheduledCallButton({
    super.key,
    required this.consultationId,
    required this.doctorId,
    required this.doctorName,
    this.doctorProfileUrl,
    required this.scheduledTime,
  });

  bool get _canJoinCall {
    // Convert both times to UTC for consistent comparison
    final now = DateTime.now().toUtc();
    final scheduledTimeUtc = scheduledTime.toUtc();
    final difference = scheduledTimeUtc.difference(now);
    // Can join 15 minutes before and up to 30 minutes after scheduled time
    return difference.inMinutes <= 15 && difference.inMinutes >= -30;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _canJoinCall
          ? () {
              startVideoCallFromConsultation(
                context: context,
                consultationId: consultationId,
                doctorId: doctorId,
                doctorName: doctorName,
                doctorProfileUrl: doctorProfileUrl,
                scheduledTime: scheduledTime,
              );
            }
          : null,
      icon: const Icon(Icons.video_call),
      label: Text(_canJoinCall ? 'Join Video Call' : 'Call not available yet'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _canJoinCall ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
