// lib/features/consult/domain/models/doctor.dart

class Doctor {
  final String id;
  final String userId;
  final String bmcdRegistrationNumber;
  final String specialization;
  final String? qualification;
  final double consultationFee;
  final DateTime? availabilityStart;
  final DateTime? availabilityEnd;
  final String? bio;
  final DateTime createdAt;

  // User details from joined table
  final String fullName;
  final String? profilePictureUrl;
  final String email;

  Doctor({
    required this.id,
    required this.userId,
    required this.bmcdRegistrationNumber,
    required this.specialization,
    this.qualification,
    required this.consultationFee,
    this.availabilityStart,
    this.availabilityEnd,
    this.bio,
    required this.createdAt,
    required this.fullName,
    this.profilePictureUrl,
    required this.email,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bmcdRegistrationNumber: json['bmcd_registration_number'] as String,
      specialization: json['specialization'] as String? ?? 'General',
      qualification: json['qualification'] as String?,
      consultationFee: (json['consultation_fee'] as num).toDouble(),
      availabilityStart: json['availability_start'] != null
          ? DateTime.parse(json['availability_start'] as String)
          : null,
      availabilityEnd: json['availability_end'] != null
          ? DateTime.parse(json['availability_end'] as String)
          : null,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      // User details from joined table
      fullName: json['users']?['full_name'] as String? ?? 'Doctor',
      profilePictureUrl: json['users']?['profile_picture_url'] as String?,
      email: json['users']?['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bmcd_registration_number': bmcdRegistrationNumber,
      'specialization': specialization,
      'qualification': qualification,
      'consultation_fee': consultationFee,
      'availability_start': availabilityStart?.toIso8601String(),
      'availability_end': availabilityEnd?.toIso8601String(),
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAvailableNow {
    if (availabilityStart == null || availabilityEnd == null) return false;
    final now = DateTime.now();
    return now.isAfter(availabilityStart!) && now.isBefore(availabilityEnd!);
  }
}
