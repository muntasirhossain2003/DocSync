// lib/features/video_call/domain/models/call_state.dart
enum CallState {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

class VideoCallInfo {
  final String consultationId;
  final String doctorId;
  final String doctorName;
  final String? doctorProfileUrl;
  final String patientId;
  final String patientName;
  final DateTime scheduledTime;

  VideoCallInfo({
    required this.consultationId,
    required this.doctorId,
    required this.doctorName,
    this.doctorProfileUrl,
    required this.patientId,
    required this.patientName,
    required this.scheduledTime,
  });
}
