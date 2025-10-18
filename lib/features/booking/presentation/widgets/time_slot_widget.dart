// lib/features/booking/presentation/widgets/time_slot_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_constants.dart';
import '../providers/booking_provider.dart';

class TimeSlotsWidget extends ConsumerWidget {
  const TimeSlotsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final slotsAsync = ref.watch(availableSlotsProvider);
    final selectedSlot = ref.watch(selectedTimeSlotProvider);
    
    return slotsAsync.when(
      data: (slots) {
        if (slots.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingXL),
              child: Text(
                'No available slots for this date',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isSelected = selectedSlot?.dateTime == slot.dateTime;

            return _buildTimeSlotCard(
              context,
              ref,
              slot: slot,
              isSelected: isSelected,
              colorScheme: colorScheme,
              textTheme: textTheme,
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacingXL),
          child: Text(
            'Error loading time slots',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(
    BuildContext context,
    WidgetRef ref, {
    required slot,
    required bool isSelected,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final isAvailable = slot.isAvailable;

    return InkWell(
      onTap: isAvailable
          ? () {
              ref.read(selectedTimeSlotProvider.notifier).state = slot;
            }
          : null,
      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXS,
          vertical: AppConstants.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : isAvailable
              ? colorScheme.surfaceContainerLow
              : colorScheme.surfaceContainerLow.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : isAvailable
                ? colorScheme.outlineVariant
                : colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            slot.formattedTime,
            style: textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimary
                  : isAvailable
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
