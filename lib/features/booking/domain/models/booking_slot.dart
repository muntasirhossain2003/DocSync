// lib/features/booking/domain/models/booking_slot.dart

class BookingSlot {
  final DateTime dateTime;
  final bool isAvailable;
  final String? reason; // Why unavailable if not available

  BookingSlot({required this.dateTime, required this.isAvailable, this.reason});

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
  // Generate slots from 9 AM to 8 PM in 30-minute intervals
  static List<BookingSlot> generateSlotsForDay(DateTime date) {
    final slots = <BookingSlot>[];
    final now = DateTime.now();

    // Start at 9 AM, end at 8 PM
    for (int hour = 9; hour < 20; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final slotTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        // Check if slot is in the past
        final isPast = slotTime.isBefore(now);

        slots.add(
          BookingSlot(
            dateTime: slotTime,
            isAvailable: !isPast,
            reason: isPast ? 'Past time' : null,
          ),
        );
      }
    }

    return slots;
  }

  // Generate slots for next N days
  static Map<DateTime, List<BookingSlot>> generateSlotsForDays(int days) {
    final slotsMap = <DateTime, List<BookingSlot>>{};
    final today = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = today.add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      slotsMap[normalizedDate] = generateSlotsForDay(date);
    }

    return slotsMap;
  }
}
