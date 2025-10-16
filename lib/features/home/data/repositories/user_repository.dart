// lib/features/home/data/repositories/user_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user.dart' as domain_user;

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<domain_user.User?> fetchCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      print('⚠️ No auth user found');
      return null;
    }

    try {
      print('📱 Fetching user with auth_id: ${authUser.id}');
      final response = await _supabase
          .from('users')
          .select('*')                  // fetch all fields
          .eq('auth_id', authUser.id)
          .maybeSingle();               // returns null if no row found

      if (response == null) {
        print('⚠️ User not found in DB');
        return null;                  // do not use authUser.id as fallback
      }

      print('✅ User data fetched: $response');
      return domain_user.User.fromJson(response);
    } catch (e) {
      print('Error fetching user from database: $e');
      return null;
    }
  }
}
