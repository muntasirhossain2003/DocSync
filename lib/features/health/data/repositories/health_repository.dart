// lib/features/health/data/repositories/health_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/health_models.dart';

class HealthRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch all prescriptions for a patient
  Future<List<Prescription>> fetchPatientPrescriptions(String patientId) async {
    try {
      final response = await _supabase
          .from('prescriptions')
          .select('''
            *,
            prescription_medications (*),
            medical_tests (*),
            doctors!inner (
              id,
              specialization,
              users!inner (
                full_name,
                profile_picture_url
              )
            )
          ''')
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Prescription.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch prescriptions: $e');
    }
  }

  /// Fetch a single prescription by ID with full details
  Future<Prescription?> fetchPrescriptionById(String prescriptionId) async {
    try {
      final response = await _supabase
          .from('prescriptions')
          .select('''
            *,
            prescription_medications (*),
            medical_tests (*),
            doctors!inner (
              id,
              specialization,
              users!inner (
                full_name,
                profile_picture_url
              )
            )
          ''')
          .eq('id', prescriptionId)
          .single();

      return Prescription.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Fetch prescriptions by consultation ID
  Future<Prescription?> fetchPrescriptionByConsultation(
    String consultationId,
  ) async {
    try {
      final response = await _supabase
          .from('prescriptions')
          .select('''
            *,
            prescription_medications (*),
            medical_tests (*),
            doctors!inner (
              id,
              specialization,
              users!inner (
                full_name,
                profile_picture_url
              )
            )
          ''')
          .eq('consultation_id', consultationId)
          .maybeSingle();

      if (response == null) return null;
      return Prescription.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
