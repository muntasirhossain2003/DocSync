// lib/features/health/presentation/providers/health_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/health_repository.dart';
import '../../domain/models/health_models.dart';

// Repository provider
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

// Provider to fetch patient prescriptions
final patientPrescriptionsProvider = FutureProvider<List<Prescription>>((
  ref,
) async {
  final repository = ref.watch(healthRepositoryProvider);
  final authUserId = Supabase.instance.client.auth.currentUser?.id;

  if (authUserId == null) {
    return [];
  }

  try {
    // Get patient ID from users table
    final userResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('auth_id', authUserId)
        .single();

    final patientId = userResponse['id'] as String;

    // Fetch prescriptions
    return await repository.fetchPatientPrescriptions(patientId);
  } catch (e) {
    return [];
  }
});

// Provider to fetch a specific prescription by ID
final prescriptionDetailProvider = FutureProvider.family<Prescription?, String>(
  (ref, prescriptionId) async {
    final repository = ref.watch(healthRepositoryProvider);

    try {
      return await repository.fetchPrescriptionById(prescriptionId);
    } catch (e) {
      return null;
    }
  },
);
