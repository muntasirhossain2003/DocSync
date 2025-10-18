// lib/features/booking/domain/models/consultation.dart

enum ConsultationStatus {
  pending,
  confirmed,
  paid,
  inProgress,
  completed,
  cancelled,
  expired,
}

enum ConsultationType { video, audio, chat }

class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String? doctorProfileUrl;
  final String patientName;
  final String? patientProfileUrl;
  final ConsultationType type;
  final ConsultationStatus status;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final double fee;
  final bool isPaid;
  final String? paymentMethod; // 'subscription' or 'direct'
  final String? notes;
  final String? agoraChannelName;
  final String? agoraToken;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    this.doctorProfileUrl,
    required this.patientName,
    this.patientProfileUrl,
    required this.type,
    required this.status,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    required this.fee,
    required this.isPaid,
    this.paymentMethod,
    this.notes,
    this.agoraChannelName,
    this.agoraToken,
    required this.createdAt,
    this.updatedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    // Map DB status to app status
    String dbStatus = json['consultation_status'] as String? ?? 'scheduled';
    ConsultationStatus appStatus = _mapDbStatusToApp(dbStatus);

    return Consultation(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String? ?? 'Doctor',
      doctorProfileUrl: json['doctor_profile_url'] as String?,
      patientName: json['patient_name'] as String? ?? 'Patient',
      patientProfileUrl: json['patient_profile_url'] as String?,
      type: ConsultationType.values.firstWhere(
        (e) => e.name == (json['consultation_type'] as String),
        orElse: () => ConsultationType.video,
      ),
      status: appStatus,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      startTime: null, // DB doesn't have start_time
      endTime: null, // DB doesn't have end_time
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      isPaid: true, // All scheduled consultations are considered paid
      paymentMethod: json['payment_method'] as String?,
      notes: null, // DB doesn't store notes in consultations table
      agoraChannelName: json['agora_channel_name'] as String?,
      agoraToken: json['agora_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Map DB status to app status
  static ConsultationStatus _mapDbStatusToApp(String dbStatus) {
    switch (dbStatus) {
      case 'scheduled':
        return ConsultationStatus.confirmed;
      case 'calling':
        return ConsultationStatus.confirmed;
      case 'in_progress':
        return ConsultationStatus.inProgress;
      case 'completed':
        return ConsultationStatus.completed;
      case 'canceled':
        return ConsultationStatus.cancelled;
      case 'rejected':
        return ConsultationStatus.cancelled;
      default:
        return ConsultationStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_profile_url': doctorProfileUrl,
      'patient_name': patientName,
      'patient_profile_url': patientProfileUrl,
      'consultation_type': type.name,
      'status': status.name,
      'scheduled_time': scheduledTime.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'fee': fee,
      'is_paid': isPaid,
      'payment_method': paymentMethod,
      'notes': notes,
      'agora_channel_name': agoraChannelName,
      'agora_token': agoraToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Check if consultation can be joined (within 5 minutes before to 15 minutes after)
  bool canJoin() {
    final now = DateTime.now();
    final startWindow = scheduledTime.subtract(const Duration(minutes: 5));
    final endWindow = scheduledTime.add(const Duration(minutes: 15));

    return now.isAfter(startWindow) &&
        now.isBefore(endWindow) &&
        isPaid &&
        status == ConsultationStatus.confirmed;
  }

  // Check if consultation is expired
  bool isExpired() {
    final now = DateTime.now();
    final expiryTime = scheduledTime.add(const Duration(minutes: 15));
    return now.isAfter(expiryTime) && status != ConsultationStatus.completed;
  }

  // Time until consultation
  Duration timeUntilConsultation() {
    return scheduledTime.difference(DateTime.now());
  }

  // Copy with method
  Consultation copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? doctorProfileUrl,
    String? patientName,
    String? patientProfileUrl,
    ConsultationType? type,
    ConsultationStatus? status,
    DateTime? scheduledTime,
    DateTime? startTime,
    DateTime? endTime,
    double? fee,
    bool? isPaid,
    String? paymentMethod,
    String? notes,
    String? agoraChannelName,
    String? agoraToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorProfileUrl: doctorProfileUrl ?? this.doctorProfileUrl,
      patientName: patientName ?? this.patientName,
      patientProfileUrl: patientProfileUrl ?? this.patientProfileUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      fee: fee ?? this.fee,
      isPaid: isPaid ?? this.isPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      agoraChannelName: agoraChannelName ?? this.agoraChannelName,
      agoraToken: agoraToken ?? this.agoraToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
