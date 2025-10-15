// Quick test to verify Supabase timestamp parsing
void main() {
  // Example timestamp from Supabase
  final supabaseTime = '2025-10-14 00:08:00+00';

  // Parse it
  final parsedTime = DateTime.parse(supabaseTime);

  print('Original: $supabaseTime');
  print('Parsed: $parsedTime');
  print('Is UTC: ${parsedTime.isUtc}');
  print('To UTC: ${parsedTime.toUtc()}');
  print('To Local: ${parsedTime.toLocal()}');

  // Calculate time difference
  final now = DateTime.now();
  print('\nCurrent time (local): $now');
  print('Current time (UTC): ${now.toUtc()}');

  final difference = parsedTime.toUtc().difference(now.toUtc());
  print('\nTime difference: ${difference.inMinutes} minutes');
  print('Time difference: ${difference.inHours} hours');
  print('Time difference: ${difference.inDays} days');

  // Smart formatting
  if (difference.inMinutes > 1440) {
    final days = (difference.inMinutes / 1440).floor();
    print('Display: Available in ${days}d');
  } else if (difference.inMinutes > 60) {
    final hours = (difference.inMinutes / 60).floor();
    print('Display: Available in ${hours}h');
  } else {
    print('Display: Available in ${difference.inMinutes}m');
  }
}
