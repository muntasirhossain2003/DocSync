// lib/features/home/presentation/providers/consultation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../consult/data/repositories/doctor_repository.dart';
import '../../../consult/domain/models/doctor.dart';

// Consultation model for home page
class ConsultationWithDoctor {
  final String id;
  final String consultationType;
  final DateTime scheduledTime;
  final String consultationStatus;
  final Doctor doctor;

  ConsultationWithDoctor({
    required this.id,
    required this.consultationType,
    required this.scheduledTime,
    required this.consultationStatus,
    required this.doctor,
  });

  factory ConsultationWithDoctor.fromJson(Map<String, dynamic> json) {
    final doctorData = json['doctors'];
    Doctor doctor;

    if (doctorData is Doctor) {
      doctor = doctorData;
    } else if (doctorData is Map<String, dynamic>) {
      doctor = Doctor.fromJson(doctorData);
    } else {
      // Handle cases where doctorData is null or not a map
      throw Exception(
        'Invalid or missing doctor data in consultation response',
      );
    }

    return ConsultationWithDoctor(
      id: json['id'] as String,
      consultationType: json['consultation_type'] as String,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      consultationStatus: json['consultation_status'] as String,
      doctor: doctor,
    );
  }

  // Check if video call is available (within 30-minute window)
  bool get isVideoCallAvailable {
    if (consultationType != 'video') return false;

    final now = DateTime.now().toUtc();
    final scheduledUtc = scheduledTime.toUtc();
    final difference = now.difference(scheduledUtc);

    // Available from scheduled time to 30 minutes after
    return difference.inMinutes >= 0 && difference.inMinutes <= 30;
  }

  // Check if consultation should be removed (more than 30 minutes past scheduled time)
  bool get shouldBeRemoved {
    final now = DateTime.now().toUtc();
    final scheduledUtc = scheduledTime.toUtc();
    final difference = now.difference(scheduledUtc);

    // Remove if more than 30 minutes past scheduled time
    return difference.inMinutes > 30;
  }

  // Get time remaining until video call is available
  Duration? get timeUntilAvailable {
    final now = DateTime.now().toUtc();
    final scheduledUtc = scheduledTime.toUtc();
    final difference = scheduledUtc.difference(now);

    if (difference.inMinutes <= 0) return null; // Already available or past
    return difference;
  }

  // Get time remaining in the 30-minute window
  Duration? get timeRemainingInWindow {
    if (!isVideoCallAvailable) return null;

    final now = DateTime.now().toUtc();
    final scheduledUtc = scheduledTime.toUtc();
    final windowEnd = scheduledUtc.add(const Duration(minutes: 30));

    return windowEnd.difference(now);
  }

  // Get user-friendly status text
  String get callStatusText {
    if (consultationType != 'video') return 'Consultation';

    final now = DateTime.now().toUtc();
    final scheduledUtc = scheduledTime.toUtc();
    final difference = now.difference(scheduledUtc);

    if (difference.inMinutes < 0) {
      // Before scheduled time
      final timeUntil = timeUntilAvailable;
      if (timeUntil != null) {
        if (timeUntil.inDays > 0) {
          return 'Available in ${timeUntil.inDays}d';
        } else if (timeUntil.inHours > 0) {
          return 'Available in ${timeUntil.inHours}h';
        } else {
          return 'Available in ${timeUntil.inMinutes}m';
        }
      }
    } else if (difference.inMinutes >= 0 && difference.inMinutes <= 30) {
      // Within 30-minute window
      final remaining = timeRemainingInWindow;
      if (remaining != null) {
        return 'Join Call (${remaining.inMinutes}m left)';
      }
      return 'Join Video Call';
    } else {
      // Past 30-minute window
      return 'Call Ended';
    }

    return 'Video Call';
  }
}

// Provider to fetch upcoming consultations for current user with time-based filtering
final upcomingConsultationsProvider =
    FutureProvider<List<ConsultationWithDoctor>>((ref) async {
      // Re-run when auth state changes
      ref.watch(authStateProvider);
      final supabase = Supabase.instance.client;
      final authUserId = supabase.auth.currentUser?.id;

      if (authUserId == null) {
        return [];
      }

      try {
        // First get the user's ID from users table
        final userResponse = await supabase
            .from('users')
            .select('id')
            .eq('auth_id', authUserId)
            .single();

        final userId = userResponse['id'] as String;

        // Get current time minus 30 minutes (to exclude expired consultations)
        final cutoffTime = DateTime.now()
            .toUtc()
            .subtract(const Duration(minutes: 30))
            .toIso8601String();

        // Fetch upcoming consultations that haven't expired
        final response = await supabase
            .from('consultations')
            .select('''
          id,
          consultation_type,
          scheduled_time,
          consultation_status,
          doctors!inner (
            id,
            user_id,
            bmcd_registration_number,
            specialization,
            qualification,
            consultation_fee,
            availability_start,
            availability_end,
            is_available,
            bio,
            created_at,
            users!inner (
              full_name,
              email,
              profile_picture_url
            )
          )
        ''')
            .eq('patient_id', userId)
            .eq('consultation_status', 'scheduled')
            .gte(
              'scheduled_time',
              cutoffTime,
            ) // Only get consultations that haven't expired
            .order('scheduled_time', ascending: true)
            .limit(10); // Increased limit to account for filtering

        print('Raw response: $response');

        final consultations = (response as List)
            .map((json) => ConsultationWithDoctor.fromJson(json))
            .where(
              (consultation) => !consultation.shouldBeRemoved,
            ) // Additional client-side filtering
            .toList();

        print('Fetched ${consultations.length} valid upcoming consultations');

        return consultations;
      } catch (e) {
        print('Error fetching consultations: $e');
        return [];
      }
    });

// Provider for real-time consultation updates (refreshes every minute)
final realTimeConsultationsProvider =
    StreamProvider<List<ConsultationWithDoctor>>((ref) {
      return Stream.periodic(
        const Duration(minutes: 1),
        (count) => count,
      ).asyncMap((_) async {
        try {
          // Refresh the consultation data every minute
          final consultations = await ref.read(
            upcomingConsultationsProvider.future,
          );

          // Auto-expire consultations that should be removed
          await _autoExpireConsultations(ref);

          return consultations;
        } catch (e) {
          print('Error in real-time consultation updates: $e');
          return <ConsultationWithDoctor>[];
        }
      });
    });

// Auto-expire consultations that are past the 30-minute window
Future<void> _autoExpireConsultations(Ref ref) async {
  try {
    final supabase = Supabase.instance.client;
    final authUserId = supabase.auth.currentUser?.id;

    if (authUserId == null) return;

    // Get user ID
    final userResponse = await supabase
        .from('users')
        .select('id')
        .eq('auth_id', authUserId)
        .single();

    final userId = userResponse['id'] as String;

    // Calculate cutoff time (30 minutes ago)
    final expiredTime = DateTime.now()
        .toUtc()
        .subtract(const Duration(minutes: 30))
        .toIso8601String();

    // Update expired consultations to 'completed' status
    await supabase
        .from('consultations')
        .update({
          'consultation_status': 'completed',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('patient_id', userId)
        .eq('consultation_status', 'scheduled')
        .lt('scheduled_time', expiredTime);

    print('Auto-expired consultations older than 30 minutes');
  } catch (e) {
    print('Error auto-expiring consultations: $e');
  }
}

// Provider to fetch top rated doctors
final topDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final repository = DoctorRepository();

  try {
    final doctors = await repository.fetchAllDoctors();

    // Return first 5 doctors as "top doctors"
    return doctors.take(5).toList();
  } catch (e) {
    print('Error fetching top doctors: $e');
    return [];
  }
});
