// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_constants.dart';
import '../providers/consultation_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/home_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _handleRefresh(WidgetRef ref) async {
    try {
      // Refresh all data providers used on the home page
      final futures = <Future>[
        ref.refresh(currentUserProvider.future),
        ref.refresh(upcomingConsultationsProvider.future),
        ref.refresh(categoriesProvider.future),
        ref.refresh(allSpecializationsProvider.future),
      ];

      // Wait for all refreshes to complete
      await Future.wait(futures);

      // Also trigger auto-expiration check
      await _autoExpireConsultations(ref);
    } catch (e) {
      // Errors are handled by individual providers
      // The refresh indicator will still complete
      print('Refresh error: $e');
    }
  }

  // Auto-expire consultations that are past the 30-minute window
  Future<void> _autoExpireConsultations(WidgetRef ref) async {
    try {
      final supabase = Supabase.instance.client;
      final authUserId = supabase.auth.currentUser?.id;

      if (authUserId == null) return;

      // Get user ID
      final userResponse = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', authUserId)
          .single();

      final userId = userResponse['id'] as String;

      // Calculate cutoff time (30 minutes ago)
      final expiredTime = DateTime.now()
          .toUtc()
          .subtract(const Duration(minutes: 30))
          .toIso8601String();

      // Update expired consultations to 'completed' status
      await supabase
          .from('consultations')
          .update({
            'consultation_status': 'completed',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('patient_id', userId)
          .eq('consultation_status', 'scheduled')
          .lt('scheduled_time', expiredTime);

      print('Auto-expired consultations older than 30 minutes');
    } catch (e) {
      print('Error auto-expiring consultations: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _handleRefresh(ref),
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(),
                  SizedBox(height: AppConstants.spacingLG),
                  UpcomingScheduleSection(),
                  SizedBox(height: AppConstants.spacingLG),
                  CategoriesSection(),
                  SizedBox(height: AppConstants.spacingLG),
                  TopDoctorsSection(),
                  SizedBox(height: AppConstants.spacingXXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
