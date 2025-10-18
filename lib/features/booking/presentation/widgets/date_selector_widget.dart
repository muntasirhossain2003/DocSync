// lib/features/booking/presentation/widgets/date_selector_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_constants.dart';
import '../providers/booking_provider.dart';

class DateSelectorWidget extends ConsumerWidget {
  const DateSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedDate = ref.watch(selectedDateProvider);

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show 14 days
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              selectedDate.year == date.year &&
              selectedDate.month == date.month &&
              selectedDate.day == date.day;

          return _buildDateCard(
            context,
            ref,
            date: date,
            isSelected: isSelected,
            colorScheme: colorScheme,
            textTheme: textTheme,
          );
        },
      ),
    );
  }

  Widget _buildDateCard(
    BuildContext context,
    WidgetRef ref, {
    required DateTime date,
    required bool isSelected,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];

    return Padding(
      padding: EdgeInsets.only(right: AppConstants.spacingSM),
      child: InkWell(
        onTap: () {
          ref.read(selectedDateProvider.notifier).state = date;
          // Clear selected time slot when date changes
          ref.read(selectedTimeSlotProvider.notifier).state = null;
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        child: Container(
          width: 70,
          padding: EdgeInsets.all(AppConstants.spacingSM),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayName,
                style: textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              SizedBox(height: AppConstants.spacingXS),
              Text(
                '${date.day}',
                style: textTheme.titleLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                monthName,
                style: textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
