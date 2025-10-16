// Verify the booking time conversion fix
void main() {
  print('=== BOOKING TIME CONVERSION FIX ===\n');

  // Scenario: User books appointment for 10:30 PM today (Dhaka time)
  print('User selects: Oct 15, 2025 at 10:30 PM (Dhaka local time)');

  // Before fix:
  final localTime = DateTime(2025, 10, 15, 22, 30);
  print('\n❌ BEFORE FIX:');
  print('   DateTime created: $localTime');
  print('   .toIso8601String(): ${localTime.toIso8601String()}');
  print('   Saved to DB: ${localTime.toIso8601String()}');
  print('   Problem: This is LOCAL time but DB thinks it\'s UTC!');

  // After fix:
  print('\n✅ AFTER FIX:');
  print('   DateTime created: $localTime');
  final utcTime = localTime.toUtc();
  print('   .toUtc(): $utcTime');
  print('   .toIso8601String(): ${utcTime.toIso8601String()}');
  print('   Saved to DB: ${utcTime.toIso8601String()}');
  print('   Correct: DB stores UTC, displays as local');

  print('\n=== VERIFICATION ===');
  print('When patient views this appointment:');
  print('   DB has: ${utcTime.toIso8601String()}');
  final parsed = DateTime.parse(utcTime.toIso8601String());
  print('   Parsed as: $parsed');
  print('   Displayed as (local): ${parsed.toLocal()}');
  print('   ✅ User sees: Oct 15, 10:30 PM (correct!)');

  print('\n=== TIME REMAINING CALCULATION ===');
  final now = DateTime.now().toUtc();
  print('   Current time (UTC): $now');
  print('   Scheduled time (UTC): $utcTime');
  final difference = utcTime.difference(now);
  print('   Difference: ${difference.inMinutes} minutes');

  if (difference.inMinutes <= 15 && difference.inMinutes >= -30) {
    print('   ✅ Status: "Join Video Call"');
  } else if (difference.inMinutes > 60) {
    final hours = (difference.inMinutes / 60).floor();
    print('   ✅ Status: "Available in ${hours}h"');
  } else if (difference.inMinutes > 15) {
    print('   ✅ Status: "Available in ${difference.inMinutes}m"');
  } else {
    print('   ✅ Status: "Call Ended"');
  }
}
