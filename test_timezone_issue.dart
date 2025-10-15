// Test to understand the timezone issue
void main() {
  // Scenario: Doctor schedules for 6:08 PM Dhaka time (Oct 14)
  // Dhaka is UTC+6
  // So 18:08 Dhaka = 12:08 UTC

  // But if stored as '2025-10-14 00:08:00+00' in database
  // That means 00:08 UTC = 06:08 Dhaka time

  final supabaseTime = '2025-10-14 00:08:00+00';
  final parsed = DateTime.parse(supabaseTime);

  print('Database timestamp (UTC): $supabaseTime');
  print('Parsed as: $parsed');
  print('In Dhaka time (UTC+6): ${parsed.toLocal()}');

  // If doctor scheduled for 6:08 AM Dhaka time
  // Database should show: 00:08 UTC
  // Which converts to: 06:08 Dhaka local

  // Let's say current time is Oct 15, 10:15 PM Dhaka
  final nowLocal = DateTime.now();
  final nowUtc = nowLocal.toUtc();

  print('\nCurrent time (local): $nowLocal');
  print('Current time (UTC): $nowUtc');

  // Calculate difference - comparing UTC to UTC
  final difference = parsed.difference(nowUtc);

  print('\nTime difference: ${difference.inMinutes} minutes');
  print('Time difference: ${difference.inHours} hours');

  // The consultation was Oct 14 at 6:08 AM Dhaka
  // Now it's Oct 15 at 10:15 PM Dhaka
  // So it was about 40 hours ago - PAST

  if (difference.isNegative) {
    print('\nThis consultation has PASSED');
  } else {
    print('\nThis consultation is UPCOMING');
  }
}
