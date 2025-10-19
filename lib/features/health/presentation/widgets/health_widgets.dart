// lib/features/health/presentation/widgets/health_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_constants.dart';
import '../pages/prescription_detail_page.dart';
import '../providers/health_provider.dart';

/// Prescription List Section
class PrescriptionListSection extends ConsumerWidget {
  const PrescriptionListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final prescriptionsAsync = ref.watch(patientPrescriptionsProvider);

    return Card(
      elevation: AppConstants.elevationLevel1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'My Prescriptions',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            prescriptionsAsync.when(
              data: (prescriptions) {
                if (prescriptions.isEmpty) {
                  return _buildEmptyState(colorScheme, textTheme);
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prescriptions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: AppConstants.spacingMD),
                  itemBuilder: (context, index) {
                    final prescription = prescriptions[index];
                    return PrescriptionListItem(prescription: prescription);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spacingXL),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) =>
                  _buildErrorState(colorScheme, textTheme, error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'No Prescriptions Yet',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Your prescriptions from consultations will appear here',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    ColorScheme colorScheme,
    TextTheme textTheme,
    String error,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Failed to load prescriptions',
            style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
          ),
        ],
      ),
    );
  }
}

/// Individual Prescription Item
class PrescriptionListItem extends StatelessWidget {
  final dynamic prescription;

  const PrescriptionListItem({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormatter = DateFormat('MMM dd, yyyy • h:mm a');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PrescriptionDetailPage(prescriptionId: prescription.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSM),
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child:
                  prescription.doctorProfileUrl != null &&
                      prescription.doctorProfileUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSM,
                      ),
                      child: Image.network(
                        prescription.doctorProfileUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.person, color: colorScheme.primary),
                      ),
                    )
                  : Icon(Icons.person, color: colorScheme.primary),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            // Prescription Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${prescription.doctorName}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prescription.doctorSpecialization,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          dateFormatter.format(
                            prescription.createdAt.toLocal(),
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (prescription.medications.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.medication_rounded,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${prescription.medications.length} medication(s)',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Arrow Icon
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Share with Doctor Section
class ShareWithDoctorSection extends StatelessWidget {
  const ShareWithDoctorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: AppConstants.elevationLevel1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share_rounded, color: colorScheme.primary, size: 24),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Share with Doctor',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Allow doctors to access your health records and prescriptions during consultations',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Manage Access'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
