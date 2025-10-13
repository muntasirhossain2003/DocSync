// lib/features/home/presentation/providers/consultation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    return ConsultationWithDoctor(
      id: json['id'] as String,
      consultationType: json['consultation_type'] as String,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      consultationStatus: json['consultation_status'] as String,
      doctor: Doctor.fromJson(json['doctors'] as Map<String, dynamic>),
    );
  }
}

// Provider to fetch upcoming consultations for current user
final upcomingConsultationsProvider =
    FutureProvider<List<ConsultationWithDoctor>>((ref) async {
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

        // Fetch upcoming consultations
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
            .gte('scheduled_time', DateTime.now().toIso8601String())
            .order('scheduled_time', ascending: true)
            .limit(5);

        print('Fetched ${(response as List).length} upcoming consultations');

        return (response)
            .map(
              (json) =>
                  ConsultationWithDoctor.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        print('Error fetching upcoming consultations: $e');
        return [];
      }
    });

// Provider to fetch top rated doctors
final topDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final repository = DoctorRepository();

  try {
    // Fetch all doctors and return top ones
    // In a real app, you'd have a rating system in the database
    final doctors = await repository.fetchAllDoctors();

    // Return first 5 doctors as "top doctors"
    return doctors.take(5).toList();
  } catch (e) {
    print('Error fetching top doctors: $e');
    return [];
  }
});
