// lib/features/booking/domain/models/booking_slot.dart

import '../../../consult/domain/models/doctor.dart';

class BookingSlot {
  final DateTime dateTime; // Device-local time for display
  final DateTime? utcDateTime; // Canonical UTC instant of the slot
  final bool isAvailable;
  final String? reason; // Why unavailable if not available

  BookingSlot({
    required this.dateTime,
    required this.isAvailable,
    this.reason,
    this.utcDateTime,
  });

  // Helper to check if this slot is in the past
  bool get isPast => dateTime.isBefore(DateTime.now());

  // Helper to format time
  String get formattedTime {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  // Helper to format date
  String get formattedDate {
    final months = [
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
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    return BookingSlot(
      dateTime: DateTime.parse(json['date_time'] as String),
      isAvailable: json['is_available'] as bool,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_time': dateTime.toIso8601String(),
      'is_available': isAvailable,
      'reason': reason,
    };
  }
}

// Helper class to generate time slots for a day
class TimeSlotGenerator {
  // Generate slots from doctor's availability times in 30-minute intervals
  // Uses day-specific schedule from the availability JSONB column
  static List<BookingSlot> generateSlotsForDay(
    DateTime date, {
    DateTime? availabilityStart,
    DateTime? availabilityEnd,
    DaySchedule? daySchedule,
  }) {
    final slots = <BookingSlot>[];
    // Use UTC 'now' to compare consistently with generated UTC slots
    final nowUtc = DateTime.now().toUtc();
    const bdOffset = Duration(hours: 6);

    // Use day-specific schedule if provided (preferred)
    if (daySchedule != null && daySchedule.available) {
      // Parse start time (format: "HH:mm" in UTC+6)
      final startParts = daySchedule.start.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);

      // Parse end time (format: "HH:mm" in UTC+6)
      final endParts = daySchedule.end.split(':');
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      // Build the day in Bangladesh time by converting the selected date to BD
      final dateBd = date.toUtc().add(bdOffset);

      // Create slot boundaries in BD local time, then convert to UTC for storage/comparison
      DateTime currentSlotBd = DateTime(
        dateBd.year,
        dateBd.month,
        dateBd.day,
        startHour,
        startMinute,
      );
      DateTime endTimeBd = DateTime(
        dateBd.year,
        dateBd.month,
        dateBd.day,
        endHour,
        endMinute,
      );

      // Convert BD times to UTC for canonical slot DateTime
      DateTime currentSlotUtc = currentSlotBd.subtract(bdOffset).toUtc();
      final endTimeUtc = endTimeBd.subtract(bdOffset).toUtc();

      while (currentSlotUtc.isBefore(endTimeUtc)) {
        // For display, we want device local; for comparison, use UTC
        final isPast = currentSlotUtc.isBefore(nowUtc);

        slots.add(
          BookingSlot(
            // Store slot time as device-local so widgets show local time naturally
            // but it represents the UTC instant of the slot.
            dateTime: currentSlotUtc.toLocal(),
            utcDateTime: currentSlotUtc,
            isAvailable: !isPast,
            reason: isPast ? 'Past time' : null,
          ),
        );

        // Advance by 30 minutes in BD time and recalc UTC
        currentSlotBd = currentSlotBd.add(const Duration(minutes: 30));
        currentSlotUtc = currentSlotBd.subtract(bdOffset).toUtc();
      }

      return slots;
    }

    // Fallback to availabilityStart/End if no day schedule
    int startHour = 9;
    int startMinute = 0;
    int endHour = 20;
    int endMinute = 0;

    // Use doctor's availability times if provided
    if (availabilityStart != null) {
      startHour = availabilityStart.hour;
      startMinute = availabilityStart.minute;
    }

    if (availabilityEnd != null) {
      endHour = availabilityEnd.hour;
      endMinute = availabilityEnd.minute;
    }

    // Generate slots in 30-minute intervals
    // Fallback: treat availabilityStart/End as BD local clock if provided
    final dateBd = date.toUtc().add(bdOffset);
    DateTime currentSlotBd = DateTime(
      dateBd.year,
      dateBd.month,
      dateBd.day,
      startHour,
      startMinute,
    );
    DateTime endTimeBd = DateTime(
      dateBd.year,
      dateBd.month,
      dateBd.day,
      endHour,
      endMinute,
    );

    DateTime currentSlotUtc = currentSlotBd.subtract(bdOffset).toUtc();
    final endTimeUtc = endTimeBd.subtract(bdOffset).toUtc();

    while (currentSlotUtc.isBefore(endTimeUtc)) {
      // Check if slot is in the past by comparing in UTC
      final isPast = currentSlotUtc.isBefore(nowUtc);

      slots.add(
        BookingSlot(
          dateTime: currentSlotUtc.toLocal(),
          utcDateTime: currentSlotUtc,
          isAvailable: !isPast,
          reason: isPast ? 'Past time' : null,
        ),
      );

      // Add 30 minutes using BD time and recalc UTC
      currentSlotBd = currentSlotBd.add(const Duration(minutes: 30));
      currentSlotUtc = currentSlotBd.subtract(bdOffset).toUtc();
    }

    return slots;
  }

  // Generate slots for next N days
  static Map<DateTime, List<BookingSlot>> generateSlotsForDays(
    int days, {
    DateTime? availabilityStart,
    DateTime? availabilityEnd,
    Map<String, DaySchedule>? availability,
  }) {
    final slotsMap = <DateTime, List<BookingSlot>>{};
    final today = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = today.add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Get day-specific schedule if availability map is provided
      DaySchedule? daySchedule;
      if (availability != null) {
        final weekday = date.weekday;
        final dayName = [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
          'sunday',
        ][weekday - 1];
        daySchedule = availability[dayName];
      }

      slotsMap[normalizedDate] = generateSlotsForDay(
        date,
        availabilityStart: availabilityStart,
        availabilityEnd: availabilityEnd,
        daySchedule: daySchedule,
      );
    }

    return slotsMap;
  }
}
