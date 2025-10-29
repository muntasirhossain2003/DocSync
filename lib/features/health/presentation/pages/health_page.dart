// lib/features/health/presentation/pages/health_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/health_provider.dart';
import '../widgets/health_widgets.dart';

class HealthPage extends ConsumerWidget {
  const HealthPage({super.key});

  Future<void> _handleRefresh(WidgetRef ref) async {
    try {
      // Refresh health-related providers
      final future = ref.refresh(patientPrescriptionsProvider.future);
      await future;
    } catch (e) {
      // Errors are handled by individual providers
      print('Health refresh error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Health Records',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(ref),
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prescriptions Section
              PrescriptionListSection(),
              SizedBox(height: 16),
              // Share with Doctor Section
              ShareWithDoctorSection(),
            ],
          ),
        ),
      ),
    );
  }
}
