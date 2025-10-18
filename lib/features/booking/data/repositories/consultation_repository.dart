// lib/features/booking/data/repositories/consultation_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/consultation.dart';

class ConsultationRepository {
  final _supabase = Supabase.instance.client;

  // Create a new consultation
  Future<Consultation> createConsultation({
    required String patientId,
    required String doctorId,
    required ConsultationType type,
    required DateTime scheduledTime,
    required double fee,
    String? notes,
  }) async {
    try {
      final response = await _supabase
          .from('consultations')
          .insert({
            'patient_id': patientId,
            'doctor_id': doctorId,
            'consultation_type': type.name,
            'consultation_status':
                'scheduled', // Use 'scheduled' as per DB schema
            'scheduled_time': scheduledTime.toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .single();

      // Transform the response to include doctor and patient names
      final transformed = {
        ...response,
        'doctor_name': response['doctor']?['users']?['full_name'] ?? 'Doctor',
        'doctor_profile_url':
            response['doctor']?['users']?['profile_picture_url'],
        'patient_name': response['patient']?['full_name'] ?? 'Patient',
        'patient_profile_url': response['patient']?['profile_picture_url'],
        'fee': fee,
        'is_paid': false,
        'notes': notes,
      };

      return Consultation.fromJson(transformed);
    } catch (e) {
      throw Exception('Failed to create consultation: $e');
    }
  }

  // Update consultation status
  Future<Consultation> updateConsultationStatus({
    required String consultationId,
    required ConsultationStatus status,
  }) async {
    try {
      final response = await _supabase
          .from('consultations')
          .update({
            'consultation_status': _mapStatusToDb(status),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consultationId)
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .single();

      return Consultation.fromJson(_transformResponse(response));
    } catch (e) {
      throw Exception('Failed to update consultation status: $e');
    }
  }

  // Map Flutter status to DB status
  String _mapStatusToDb(ConsultationStatus status) {
    switch (status) {
      case ConsultationStatus.pending:
        return 'scheduled';
      case ConsultationStatus.confirmed:
        return 'scheduled';
      case ConsultationStatus.paid:
        return 'scheduled';
      case ConsultationStatus.inProgress:
        return 'in_progress';
      case ConsultationStatus.completed:
        return 'completed';
      case ConsultationStatus.cancelled:
        return 'canceled';
      case ConsultationStatus.expired:
        return 'canceled';
    }
  }

  // Transform response to include names
  Map<String, dynamic> _transformResponse(Map<String, dynamic> response) {
    return {
      ...response,
      'doctor_name': response['doctor']?['users']?['full_name'] ?? 'Doctor',
      'doctor_profile_url':
          response['doctor']?['users']?['profile_picture_url'],
      'patient_name': response['patient']?['full_name'] ?? 'Patient',
      'patient_profile_url': response['patient']?['profile_picture_url'],
    };
  }

  // Mark consultation as paid
  Future<Consultation> markAsPaid({
    required String consultationId,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      final response = await _supabase
          .from('consultations')
          .update({
            'consultation_status':
                'scheduled', // Paid consultations remain scheduled
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consultationId)
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .single();

      return Consultation.fromJson(_transformResponse(response));
    } catch (e) {
      throw Exception('Failed to mark consultation as paid: $e');
    }
  }

  // Get consultation by ID
  Future<Consultation> getConsultation(String consultationId) async {
    try {
      final response = await _supabase
          .from('consultations')
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .eq('id', consultationId)
          .single();

      return Consultation.fromJson(_transformResponse(response));
    } catch (e) {
      throw Exception('Failed to fetch consultation: $e');
    }
  }

  // Get patient's consultations
  Future<List<Consultation>> getPatientConsultations(String patientId) async {
    try {
      final response = await _supabase
          .from('consultations')
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .eq('patient_id', patientId)
          .order('scheduled_time', ascending: false);

      return (response as List)
          .map((json) => Consultation.fromJson(_transformResponse(json)))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch patient consultations: $e');
    }
  }

  // Get upcoming consultations for patient
  Future<List<Consultation>> getUpcomingConsultations(String patientId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('consultations')
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .eq('patient_id', patientId)
          .gte('scheduled_time', now)
          .or(
            'consultation_status.eq.scheduled,consultation_status.eq.in_progress',
          )
          .order('scheduled_time', ascending: true);

      return (response as List)
          .map((json) => Consultation.fromJson(_transformResponse(json)))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming consultations: $e');
    }
  }

  // Cancel consultation
  Future<Consultation> cancelConsultation(String consultationId) async {
    try {
      final response = await _supabase
          .from('consultations')
          .update({
            'consultation_status': 'canceled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consultationId)
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .single();

      return Consultation.fromJson(_transformResponse(response));
    } catch (e) {
      throw Exception('Failed to cancel consultation: $e');
    }
  }

  // Start consultation (update start time and status)
  Future<Consultation> startConsultation(String consultationId) async {
    try {
      final response = await _supabase
          .from('consultations')
          .update({
            'consultation_status': 'in_progress',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consultationId)
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .single();

      return Consultation.fromJson(_transformResponse(response));
    } catch (e) {
      throw Exception('Failed to start consultation: $e');
    }
  }

  // End consultation (update end time and status)
  Future<Consultation> endConsultation(String consultationId) async {
    try {
      final response = await _supabase
          .from('consultations')
          .update({
            'consultation_status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consultationId)
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .single();

      return Consultation.fromJson(_transformResponse(response));
    } catch (e) {
      throw Exception('Failed to end consultation: $e');
    }
  }

  // Auto-expire old unpaid consultations
  Future<void> expireUnpaidConsultations() async {
    try {
      final expiryTime = DateTime.now()
          .subtract(const Duration(minutes: 15))
          .toIso8601String();

      await _supabase
          .from('consultations')
          .update({
            'consultation_status': 'canceled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('consultation_status', 'scheduled')
          .lt('scheduled_time', expiryTime);
    } catch (e) {
      throw Exception('Failed to expire consultations: $e');
    }
  }

  // Update Agora channel details
  Future<Consultation> updateAgoraDetails({
    required String consultationId,
    required String channelName,
    String? token,
  }) async {
    try {
      final response = await _supabase
          .from('consultations')
          .update({
            'agora_channel_name': channelName,
            'agora_token': token,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consultationId)
          .select('''
            *,
            patient:patient_id(id, full_name, profile_picture_url),
            doctor:doctor_id(id, users!user_id(full_name, profile_picture_url))
          ''')
          .single();

      return Consultation.fromJson(_transformResponse(response));
    } catch (e) {
      throw Exception('Failed to update Agora details: $e');
    }
  }
}
