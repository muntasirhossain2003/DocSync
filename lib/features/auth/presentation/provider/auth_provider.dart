import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final authStateProvider = StreamProvider<AuthState?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((event) => event);
});

// Session provider that updates when auth state changes
final sessionProvider = Provider<Session?>((ref) {
  // Watch auth state to trigger updates on login/logout
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (state) => state?.session);
});

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(sessionProvider) != null,
);
