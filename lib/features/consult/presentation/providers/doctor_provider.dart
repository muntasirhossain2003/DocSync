// lib/features/consult/presentation/providers/doctor_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/doctor_repository.dart';
import '../../domain/models/doctor.dart';

// Repository provider
final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

// All doctors provider
final doctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.fetchAllDoctors();
});

// Search provider with state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered doctors based on search
final filteredDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final repository = ref.watch(doctorRepositoryProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) {
    return repository.fetchAllDoctors();
  }

  return repository.searchDoctors(query);
});

// Single doctor provider
final doctorByIdProvider = FutureProvider.family<Doctor?, String>((
  ref,
  doctorId,
) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.fetchDoctorById(doctorId);
});

// Specializations list (you can customize this)
final specializationsProvider = Provider<List<String>>((ref) {
  return [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Orthopedic',
    'Gynecologist',
    'Psychiatrist',
    'Dentist',
    'ENT Specialist',
  ];
});
