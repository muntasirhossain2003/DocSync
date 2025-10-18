// lib/features/booking/presentation/providers/consultation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/consultation_repository.dart';
import '../../domain/models/consultation.dart';

// Repository provider
final consultationRepositoryProvider2 = Provider<ConsultationRepository>((ref) {
  return ConsultationRepository();
});

// Get all consultations for current user
final myConsultationsProvider = FutureProvider<List<Consultation>>((ref) async {
  final repository = ref.watch(consultationRepositoryProvider2);

  try {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) return [];

    final userResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('auth_id', authUser.id)
        .single();

    final userId = userResponse['id'] as String;
    return await repository.getPatientConsultations(userId);
  } catch (e) {
    return [];
  }
});

// Get upcoming consultations
final upcomingConsultationsProvider2 = FutureProvider<List<Consultation>>((
  ref,
) async {
  final repository = ref.watch(consultationRepositoryProvider2);

  try {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) return [];

    final userResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('auth_id', authUser.id)
        .single();

    final userId = userResponse['id'] as String;
    return await repository.getUpcomingConsultations(userId);
  } catch (e) {
    return [];
  }
});

// Get consultation by ID
final consultationByIdProvider = FutureProvider.family<Consultation?, String>((
  ref,
  consultationId,
) async {
  final repository = ref.watch(consultationRepositoryProvider2);

  try {
    return await repository.getConsultation(consultationId);
  } catch (e) {
    return null;
  }
});

// Consultation actions notifier
class ConsultationActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ConsultationRepository _repository;

  ConsultationActionsNotifier(this._repository)
    : super(const AsyncValue.data(null));

  Future<bool> cancelConsultation(String consultationId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelConsultation(consultationId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> startConsultation(String consultationId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.startConsultation(consultationId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> endConsultation(String consultationId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.endConsultation(consultationId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> expireUnpaidConsultations() async {
    try {
      await _repository.expireUnpaidConsultations();
    } catch (e) {
      // Silently fail, this is a background task
    }
  }
}

// Consultation actions provider
final consultationActionsProvider =
    StateNotifierProvider<ConsultationActionsNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(consultationRepositoryProvider2);
      return ConsultationActionsNotifier(repository);
    });
