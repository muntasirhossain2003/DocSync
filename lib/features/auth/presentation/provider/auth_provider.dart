import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final authStateProvider = StreamProvider<AuthState?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((event) => event);
});

final sessionProvider = Provider<Session?>(
  (ref) => Supabase.instance.client.auth.currentSession,
);

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(sessionProvider) != null,
);
