// Debug current time and see what timestamp would give us "2 minutes away"
void main() {
  final now = DateTime.now();
  final nowUtc = now.toUtc();

  print('=== CURRENT TIME ===');
  print('Local time: $now');
  print('UTC time: $nowUtc');

  print('\n=== IF APPOINTMENT IS 2 MINUTES AWAY ===');
  // What should the database timestamp be for "2 minutes from now"?
  final twoMinutesLater = nowUtc.add(Duration(minutes: 2));
  print('Scheduled time (UTC): $twoMinutesLater');
  print('Scheduled time (Local): ${twoMinutesLater.toLocal()}');
  print('Database should have: ${twoMinutesLater.toIso8601String()}');

  print('\n=== IF DATABASE HAS 6 HOURS OFFSET ===');
  // If showing 6 hours when it should be 2 minutes...
  // Maybe the database has the time in Dhaka local but marked as UTC?

  // Example: If scheduled for 10:30 PM Dhaka (now is 10:28 PM Dhaka)
  // That's 4:30 PM UTC (now is 4:28 PM UTC) = 2 minutes away

  // But if database stores "22:30:00+00" (treating Dhaka time AS UTC)
  // Then it's actually 22:30 UTC = 4:30 AM next day Dhaka = 6 hours from now!

  print('Scenario: Database stores LOCAL time as UTC');
  print('If appointment is 10:30 PM Dhaka (current: 10:28 PM):');
  print(
    '  Wrong: Database has "2025-10-15 22:30:00+00" (treating 22:30 as UTC)',
  );
  print(
    '  That would be: ${DateTime.parse("2025-10-15 22:30:00+00").toLocal()} local',
  );

  final wrongTimestamp = DateTime.parse("2025-10-15 22:30:00+00");
  final wrongDiff = wrongTimestamp.difference(nowUtc);
  print(
    '  Difference from now: ${wrongDiff.inHours}h ${wrongDiff.inMinutes % 60}m',
  );

  print('\n  Right: Database should have "2025-10-15 16:30:00+00" (UTC)');
  final rightTimestamp = DateTime.parse("2025-10-15 16:30:00+00");
  final rightDiff = rightTimestamp.difference(nowUtc);
  print('  That would be: ${rightTimestamp.toLocal()} local');
  print('  Difference from now: ${rightDiff.inMinutes}m');

  print('\n=== SOLUTION ===');
  print(
    'The database is likely storing Dhaka local time with +00 timezone marker',
  );
  print('We need to check how the consultation is being created!');
}
