// lib/features/home/data/repositories/user_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user.dart' as domain_user;

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<domain_user.User?> fetchCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select('id, full_name, profile_picture_url')
          .eq('auth_id', authUser.id)
          .single();

      return domain_user.User.fromJson(response);
    } catch (e) {
      // If user not found in users table, return a fallback user
      return domain_user.User(
        id: authUser.id,
        firstName: authUser.email?.split('@').first ?? 'User',
        profilePictureUrl: null,
      );
    }
  }
}
