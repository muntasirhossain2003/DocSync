// lib/features/home/presentation/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user.dart' as domain_user;

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

final currentUserProvider = FutureProvider<domain_user.User?>((ref) async {
  // Re-run when auth state changes (login/logout/switch user)
  ref.watch(authStateProvider);

  final repository = ref.watch(userRepositoryProvider);
  return repository.fetchCurrentUser();
});
