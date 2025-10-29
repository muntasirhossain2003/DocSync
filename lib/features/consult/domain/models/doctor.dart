// lib/features/consult/domain/models/doctor.dart

// Day schedule model for availability
class DaySchedule {
  final String start; // Format: "HH:mm"
  final String end; // Format: "HH:mm"
  final bool available;

  DaySchedule({
    required this.start,
    required this.end,
    required this.available,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      start: json['start'] as String,
      end: json['end'] as String,
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end, 'available': available};
  }
}

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
  final bool isAvailable; // Doctor's availability status from database
  final Map<String, DaySchedule>? availability; // JSONB availability schedule

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
    required this.isAvailable,
    this.availability,
    required this.fullName,
    this.profilePictureUrl,
    required this.email,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    // Parse availability JSONB field
    Map<String, DaySchedule>? availabilityMap;
    if (json['availability'] != null) {
      final availabilityJson = json['availability'] as Map<String, dynamic>;
      availabilityMap = availabilityJson.map(
        (key, value) => MapEntry(
          key.toLowerCase(),
          DaySchedule.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

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
      isAvailable: json['is_available'] as bool? ?? false,
      availability: availabilityMap,
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
      'availability': availability?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  // Helper method to get schedule for a specific day
  DaySchedule? getScheduleForDay(DateTime date) {
    if (availability == null) return null;

    // Convert the provided date to Bangladesh local calendar day (UTC+6)
    // regardless of the device timezone, so that availability JSON aligns
    // with how times are defined in the DB (Asia/Dhaka).
    const bdOffset = Duration(hours: 6);
    final bdDate = date.toUtc().add(bdOffset);

    final weekday = bdDate.weekday;
    final dayName = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ][weekday - 1];

    return availability![dayName];
  }

  // Getter that returns the database is_available field
  // This is calculated on the backend based on:
  // - is_online = true (doctor is currently online)
  // OR
  // - availability schedule is set (doctor has defined working hours)
  bool get isAvailableNow {
    return isAvailable;
  }
}
