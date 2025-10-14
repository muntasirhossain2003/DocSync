// lib/features/consult/presentation/providers/doctor_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../domain/models/doctor.dart';

// Repository provider
final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

// All doctors
final doctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final repo = ref.watch(doctorRepositoryProvider);
  return repo.fetchAllDoctors();
});

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected specialization
final selectedSpecializationProvider = StateProvider<String?>((ref) => null);

// Combined filter
final filteredDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final repo = ref.watch(doctorRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  final specialization = ref.watch(selectedSpecializationProvider);

  // If specialization only
  if ((query.isEmpty || query.trim().isEmpty) &&
      (specialization == null || specialization.isEmpty)) {
    return repo.fetchAllDoctors();
  }

  // If specialization and query both
  if (specialization != null && specialization.isNotEmpty && query.isNotEmpty) {
    final doctors = await repo.fetchDoctorsBySpecialization(specialization);
    return doctors
        .where((d) =>
            d.fullName.toLowerCase().contains(query.toLowerCase()) ||
            d.specialization.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Only specialization
  if (specialization != null && specialization.isNotEmpty) {
    return repo.fetchDoctorsBySpecialization(specialization);
  }

  // Only search query
  return repo.searchDoctors(query);
});

// Specializations list
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
