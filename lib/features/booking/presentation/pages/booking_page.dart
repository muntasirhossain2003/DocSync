// lib/features/booking/presentation/pages/booking_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_constants.dart';
import '../../../consult/domain/models/doctor.dart';
import '../../../home/presentation/providers/consultation_provider.dart';
import '../../domain/models/consultation.dart';
import '../providers/booking_provider.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/doctor_info_card.dart';
import '../widgets/time_slot_widget.dart';

class BookingPage extends ConsumerStatefulWidget {
  final Doctor doctor;

  const BookingPage({super.key, required this.doctor});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the selected doctor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedDoctorProvider.notifier).state = widget.doctor;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _proceedToCheckout() {
    final selectedSlot = ref.read(selectedTimeSlotProvider);

    if (selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!selectedSlot.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected slot is not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create booking and navigate to checkout
    final consultationType = ref.read(selectedConsultationTypeProvider);
    final notes = _notesController.text.trim();

    ref.read(consultationNotesProvider.notifier).state = notes;

    // Create the consultation using the canonical UTC instant of the slot
    final utcInstant =
        selectedSlot.utcDateTime ?? selectedSlot.dateTime.toUtc();
    _createBooking(utcInstant, consultationType, notes);
  }

  Future<void> _createBooking(
    DateTime scheduledTime,
    ConsultationType type,
    String notes,
  ) async {
    final consultation = await ref
        .read(bookingProvider.notifier)
        .createBooking(
          doctor: widget.doctor,
          scheduledTime: scheduledTime,
          type: type,
          notes: notes.isEmpty ? null : notes,
        );

    if (consultation != null && mounted) {
      // Immediately refresh upcoming consultations so Home reflects the new booking
      ref.invalidate(upcomingConsultationsProvider);
      // Navigate to checkout page
      context.push('/booking/checkout', extra: consultation);
    } else if (mounted) {
      final error = ref.read(bookingProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to create booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedSlot = ref.watch(selectedTimeSlotProvider);
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Book Consultation', style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: bookingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Doctor Info Card
                  DoctorInfoCard(doctor: widget.doctor),

                  const SizedBox(height: AppConstants.spacingLG),

                  // Consultation Type - Video Only (no selector needed)
                  // Automatically defaults to video consultation

                  // const SizedBox(height: AppConstants.spacingLG),

                  // Date Selector
                  Text(
                    'Select Date',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSM),
                  const DateSelectorWidget(),

                  const SizedBox(height: AppConstants.spacingLG),

                  // Time Slots
                  Text(
                    'Select Time Slot',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSM),
                  const TimeSlotsWidget(),

                  const SizedBox(height: AppConstants.spacingLG),

                  // Notes (Optional)
                  Text(
                    'Additional Notes (Optional)',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSM),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe your symptoms or concerns...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMD,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXL),

                  // Summary Card
                  if (selectedSlot != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMD),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMD,
                        ),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Summary',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingSM),
                          _buildSummaryRow(
                            'Date',
                            selectedSlot.formattedDate,
                            textTheme,
                            colorScheme,
                          ),
                          _buildSummaryRow(
                            'Time',
                            selectedSlot.formattedTime,
                            textTheme,
                            colorScheme,
                          ),
                          _buildSummaryRow(
                            'Fee',
                            '৳${widget.doctor.consultationFee.toStringAsFixed(0)}',
                            textTheme,
                            colorScheme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLG),
                  ],

                  // Proceed Button
                  ElevatedButton(
                    onPressed: selectedSlot != null && selectedSlot.isAvailable
                        ? _proceedToCheckout
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingMD,
                      ),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMD,
                        ),
                      ),
                    ),
                    child: Text(
                      'Proceed to Checkout',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.surface,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXL),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
