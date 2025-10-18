// lib/features/booking/presentation/providers/booking_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../consult/domain/models/doctor.dart';
import '../../data/repositories/consultation_repository.dart';
import '../../data/services/payment_service.dart';
import '../../domain/models/booking_slot.dart';
import '../../domain/models/consultation.dart';
import '../../domain/models/payment_method.dart';

// Repository providers
final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  return ConsultationRepository();
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

// Selected doctor for booking
final selectedDoctorProvider = StateProvider<Doctor?>((ref) => null);

// Selected date for booking
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected time slot
final selectedTimeSlotProvider = StateProvider<BookingSlot?>((ref) => null);

// Consultation type (video, audio, chat)
final selectedConsultationTypeProvider = StateProvider<ConsultationType>(
  (ref) => ConsultationType.video,
);

// Notes for consultation
final consultationNotesProvider = StateProvider<String>((ref) => '');

// Available time slots for selected date
final availableSlotsProvider = FutureProvider<List<BookingSlot>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final doctor = ref.watch(selectedDoctorProvider);

  if (doctor == null) {
    return [];
  }

  // Get day-specific schedule from doctor's availability
  final daySchedule = doctor.getScheduleForDay(selectedDate);

  // Generate slots based on doctor's day-specific availability
  final slots = TimeSlotGenerator.generateSlotsForDay(
    selectedDate,
    availabilityStart: doctor.availabilityStart,
    availabilityEnd: doctor.availabilityEnd,
    daySchedule: daySchedule,
  );

  // TODO: Filter out already booked slots by checking with backend
  // For now, just return all generated slots
  return slots;
});

// Booking creation state
class BookingState {
  final bool isLoading;
  final Consultation? consultation;
  final String? error;

  BookingState({this.isLoading = false, this.consultation, this.error});

  BookingState copyWith({
    bool? isLoading,
    Consultation? consultation,
    String? error,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      consultation: consultation ?? this.consultation,
      error: error,
    );
  }
}

// Booking state notifier
class BookingNotifier extends StateNotifier<BookingState> {
  final ConsultationRepository _repository;

  BookingNotifier(this._repository) : super(BookingState());

  Future<Consultation?> createBooking({
    required Doctor doctor,
    required DateTime scheduledTime,
    required ConsultationType type,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current user
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user details from users table
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('auth_id', authUser.id)
          .single();

      final userId = userResponse['id'] as String;

      // Create consultation
      final consultation = await _repository.createConsultation(
        patientId: userId,
        doctorId: doctor.id,
        type: type,
        scheduledTime: scheduledTime,
        fee: doctor.consultationFee,
        notes: notes,
      );

      state = state.copyWith(isLoading: false, consultation: consultation);

      return consultation;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = BookingState();
  }
}

// Booking provider
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((
  ref,
) {
  final repository = ref.watch(consultationRepositoryProvider);
  return BookingNotifier(repository);
});

// Payment state
class PaymentState {
  final bool isProcessing;
  final PaymentResult? result;
  final String? error;

  PaymentState({this.isProcessing = false, this.result, this.error});

  PaymentState copyWith({
    bool? isProcessing,
    PaymentResult? result,
    String? error,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      result: result ?? this.result,
      error: error,
    );
  }
}

// Payment notifier
class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentService _service;
  final ConsultationRepository _repository;

  PaymentNotifier(this._service, this._repository) : super(PaymentState());

  Future<bool> processPayment({
    required Consultation consultation,
    required PaymentType paymentType,
    required double finalAmount, // Use the discounted amount
  }) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // Get current user
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user ID
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('auth_id', authUser.id)
          .single();

      final userId = userResponse['id'] as String;

      // Process payment with the final (discounted) amount
      final result = await _service.processPayment(
        paymentType: paymentType,
        userId: userId,
        consultationId: consultation.id,
        amount: finalAmount,
      );

      if (result.success) {
        // Calculate discount information
        final originalFee = consultation.fee;
        final discountAmount = originalFee - finalAmount;

        // Record payment in consultation_payments table
        await _service.recordPayment(
          consultationId: consultation.id,
          userId: userId,
          paymentType: paymentType,
          transactionId: result.transactionId ?? 'N/A',
          amount: finalAmount,
          originalAmount: originalFee,
          discountApplied: discountAmount,
        );

        // Mark consultation as paid
        await _repository.markAsPaid(
          consultationId: consultation.id,
          paymentMethod: paymentType.name,
          transactionId: result.transactionId,
        );

        state = state.copyWith(isProcessing: false, result: result);
        return true;
      } else {
        state = state.copyWith(isProcessing: false, error: result.errorMessage);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = PaymentState();
  }
}

// Payment provider
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((
  ref,
) {
  final service = ref.watch(paymentServiceProvider);
  final repository = ref.watch(consultationRepositoryProvider);
  return PaymentNotifier(service, repository);
});

// Selected payment method
final selectedPaymentMethodProvider = StateProvider<PaymentType?>(
  (ref) => null,
);

// Check if user has active subscription
final hasActiveSubscriptionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(paymentServiceProvider);

  try {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) return false;

    final userResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('auth_id', authUser.id)
        .single();

    final userId = userResponse['id'] as String;
    return await service.hasActiveSubscription(userId);
  } catch (e) {
    return false;
  }
});

// Calculate discounted fee based on subscription
final discountedFeeProvider =
    FutureProvider.family<Map<String, dynamic>, double>((
      ref,
      originalFee,
    ) async {
      final service = ref.watch(paymentServiceProvider);

      try {
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser == null) {
          return {
            'originalFee': originalFee,
            'discountPercentage': 0,
            'discountedFee': originalFee,
            'hasSubscription': false,
          };
        }

        final userResponse = await Supabase.instance.client
            .from('users')
            .select('id')
            .eq('auth_id', authUser.id)
            .single();

        final userId = userResponse['id'] as String;
        return await service.calculateDiscountedFee(
          userId: userId,
          originalFee: originalFee,
        );
      } catch (e) {
        return {
          'originalFee': originalFee,
          'discountPercentage': 0,
          'discountedFee': originalFee,
          'hasSubscription': false,
        };
      }
    });
