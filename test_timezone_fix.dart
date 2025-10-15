import 'package:intl/intl.dart';

// Test to verify timezone handling is correct
void main() {
  print('=== TIMEZONE FIX VERIFICATION ===\n');

  // Example: Doctor schedules appointment for Oct 16, 2025 at 10:00 AM Dhaka time
  // Dhaka is UTC+6, so 10:00 AM Dhaka = 4:00 AM UTC
  // Database should store: 2025-10-16 04:00:00+00

  final supabaseTimestamp = '2025-10-16 04:00:00+00';
  final scheduledTime = DateTime.parse(supabaseTimestamp);

  print('1. DATABASE TIMESTAMP (UTC): $supabaseTimestamp');
  print('   Parsed as: $scheduledTime');
  print('   Is UTC: ${scheduledTime.isUtc}');

  print('\n2. CONVERT TO LOCAL (DHAKA TIME):');
  final localTime = scheduledTime.toLocal();
  print('   Local time: $localTime');

  print('\n3. DISPLAY FORMAT (for user):');
  final dateFormatter = DateFormat('MMM dd, h:mma');
  print('   UTC format: ${dateFormatter.format(scheduledTime)}');
  print('   LOCAL format: ${dateFormatter.format(localTime)}');
  print('   ✅ User sees: ${dateFormatter.format(localTime)}');

  print('\n4. TIME REMAINING CALCULATION:');
  // For calculating time remaining, compare UTC to UTC
  final nowUtc = DateTime.now().toUtc();
  final scheduledUtc = scheduledTime.toUtc();
  final difference = scheduledUtc.difference(nowUtc);

  print('   Current time (UTC): $nowUtc');
  print('   Scheduled time (UTC): $scheduledUtc');
  print(
    '   Difference: ${difference.inHours} hours (${difference.inMinutes} minutes)',
  );

  if (difference.inMinutes > 1440) {
    final days = (difference.inMinutes / 1440).floor();
    print('   ✅ Display: "Available in ${days}d"');
  } else if (difference.inMinutes > 60) {
    final hours = (difference.inMinutes / 60).floor();
    print('   ✅ Display: "Available in ${hours}h"');
  } else if (difference.inMinutes > 15) {
    print('   ✅ Display: "Available in ${difference.inMinutes}m"');
  } else if (difference.inMinutes >= -30) {
    print('   ✅ Display: "Join Video Call"');
  } else {
    print('   ✅ Display: "Call Ended"');
  }

  print('\n=== SUMMARY ===');
  print('✓ Database stores time in UTC');
  print('✓ Display to user in LOCAL time (Dhaka)');
  print('✓ Calculate remaining time using UTC comparison');
  print('✓ This ensures consistency across different timezones');
}
