// lib/features/home/presentation/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/user_repository.dart';
import '../../domain/models/user.dart' as domain_user;

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

final currentUserProvider = FutureProvider<domain_user.User?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.fetchCurrentUser();
});
