// lib/features/consult/data/repositories/doctor_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/doctor.dart';

class DoctorRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all doctors with user details
  Future<List<Doctor>> fetchAllDoctors() async {
    try {
      final response = await _supabase
          .from('doctors')
          .select('''
            *,
            users!inner (
              full_name,
              email,
              profile_picture_url
            )
          ''')
          .order('created_at', ascending: false);

      print('Fetched ${(response as List).length} doctors');
      final doctors = (response).map((json) {
        final doctor = Doctor.fromJson(json as Map<String, dynamic>);
        print(
          'Doctor: ${doctor.fullName}, ID: ${doctor.id}, UserID: ${doctor.userId}',
        );
        return doctor;
      }).toList();
      return doctors;
    } catch (e) {
      print('Error fetching doctors: $e');
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  /// Search doctors by name or specialization
  Future<List<Doctor>> searchDoctors(String query) async {
    try {
      if (query.isEmpty) {
        return fetchAllDoctors();
      }

      // Fetch all doctors and filter in memory since we can't use OR on joined tables
      final allDoctors = await fetchAllDoctors();
      final lowerQuery = query.toLowerCase();

      return allDoctors.where((doctor) {
        return doctor.fullName.toLowerCase().contains(lowerQuery) ||
            doctor.specialization.toLowerCase().contains(lowerQuery) ||
            (doctor.qualification?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching doctors: $e');
      throw Exception('Failed to search doctors: $e');
    }
  }

  /// Fetch doctors by specialization
  Future<List<Doctor>> fetchDoctorsBySpecialization(
    String specialization,
  ) async {
    try {
      final response = await _supabase
          .from('doctors')
          .select('''
            *,
            users!inner (
              full_name,
              email,
              profile_picture_url
            )
          ''')
          .eq('specialization', specialization)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Doctor.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching doctors by specialization: $e');
      throw Exception('Failed to fetch doctors by specialization: $e');
    }
  }

  /// Fetch single doctor by ID
  Future<Doctor?> fetchDoctorById(String doctorId) async {
    try {
      final response = await _supabase
          .from('doctors')
          .select('''
            *,
            users!inner (
              full_name,
              email,
              profile_picture_url
            )
          ''')
          .eq('id', doctorId)
          .single();

      return Doctor.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching doctor by ID: $e');
      return null;
    }
  }

  /// Book a consultation
  Future<String> bookConsultation({
    required String patientId,
    required String doctorId,
    required String consultationType,
    required DateTime scheduledTime,
  }) async {
    try {
      final response = await _supabase
          .from('consultations')
          .insert({
            'patient_id': patientId,
            'doctor_id': doctorId,
            'consultation_type': consultationType,
            'scheduled_time': scheduledTime.toUtc().toIso8601String(),
            'consultation_status': 'scheduled',
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error booking consultation: $e');
      throw Exception('Failed to book consultation: $e');
    }
  }

  /// Fetch consultations for current user
  Future<List<Map<String, dynamic>>> fetchUserConsultations(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('consultations')
          .select('''
            *,
            doctors!inner (
              *,
              users!inner (
                full_name,
                profile_picture_url
              )
            )
          ''')
          .eq('patient_id', userId)
          .order('scheduled_time', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching user consultations: $e');
      throw Exception('Failed to fetch consultations: $e');
    }
  }
}
