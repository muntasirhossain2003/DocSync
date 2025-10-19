// lib/features/health/presentation/pages/prescription_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_constants.dart';
import '../../domain/models/health_models.dart';
import '../providers/health_provider.dart';

class PrescriptionDetailPage extends ConsumerWidget {
  final String prescriptionId;

  const PrescriptionDetailPage({super.key, required this.prescriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final prescriptionAsync = ref.watch(
      prescriptionDetailProvider(prescriptionId),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Prescription Details',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement share/download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download feature coming soon')),
              );
            },
            icon: const Icon(Icons.file_download_outlined),
          ),
        ],
      ),
      body: prescriptionAsync.when(
        data: (prescription) {
          if (prescription == null) {
            return _buildNotFoundState(colorScheme, textTheme);
          }
          return _buildPrescriptionContent(
            context,
            prescription,
            colorScheme,
            textTheme,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(colorScheme, textTheme),
      ),
    );
  }

  Widget _buildPrescriptionContent(
    BuildContext context,
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Doctor Info Card
          _buildDoctorCard(prescription, colorScheme, textTheme),
          const SizedBox(height: AppConstants.spacingMD),

          // Prescription Date & ID
          _buildInfoCard(prescription, colorScheme, textTheme),
          const SizedBox(height: AppConstants.spacingMD),

          // Diagnosis
          if (prescription.diagnosis != null &&
              prescription.diagnosis!.isNotEmpty)
            _buildDiagnosisCard(prescription, colorScheme, textTheme),
          if (prescription.diagnosis != null &&
              prescription.diagnosis!.isNotEmpty)
            const SizedBox(height: AppConstants.spacingMD),

          // Symptoms
          if (prescription.symptoms != null &&
              prescription.symptoms!.isNotEmpty)
            _buildSymptomsCard(prescription, colorScheme, textTheme),
          if (prescription.symptoms != null &&
              prescription.symptoms!.isNotEmpty)
            const SizedBox(height: AppConstants.spacingMD),

          // Medications
          if (prescription.medications.isNotEmpty)
            _buildMedicationsCard(prescription, colorScheme, textTheme),
          if (prescription.medications.isNotEmpty)
            const SizedBox(height: AppConstants.spacingMD),

          // Medical Tests
          if (prescription.tests.isNotEmpty)
            _buildTestsCard(prescription, colorScheme, textTheme),
          if (prescription.tests.isNotEmpty)
            const SizedBox(height: AppConstants.spacingMD),

          // Medical Notes
          if (prescription.medicalNotes != null &&
              prescription.medicalNotes!.isNotEmpty)
            _buildNotesCard(prescription, colorScheme, textTheme),
          if (prescription.medicalNotes != null &&
              prescription.medicalNotes!.isNotEmpty)
            const SizedBox(height: AppConstants.spacingMD),

          // Follow-up Date
          if (prescription.followUpDate != null)
            _buildFollowUpCard(prescription, colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      elevation: AppConstants.elevationLevel1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child:
                  prescription.doctorProfileUrl != null &&
                      prescription.doctorProfileUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMD,
                      ),
                      child: Image.network(
                        prescription.doctorProfileUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(Icons.person, size: 32, color: colorScheme.primary),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${prescription.doctorName}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prescription.doctorSpecialization,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final dateFormatter = DateFormat('MMMM dd, yyyy • h:mm a');

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
                Icon(Icons.info_outline, color: colorScheme.primary),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Prescription Information',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            _buildInfoRow(
              'Date Issued',
              dateFormatter.format(prescription.createdAt.toLocal()),
              colorScheme,
              textTheme,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            _buildInfoRow(
              'Prescription ID',
              prescription.id.substring(0, 8).toUpperCase(),
              colorScheme,
              textTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard(
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
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
                Icon(Icons.medical_services, color: colorScheme.primary),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Diagnosis',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(prescription.diagnosis!, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCard(
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
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
                Icon(Icons.sick_outlined, color: colorScheme.secondary),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Symptoms',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(prescription.symptoms!, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsCard(
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
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
                Icon(Icons.medication_rounded, color: colorScheme.secondary),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Medications',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prescription.medications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: AppConstants.spacingMD),
              itemBuilder: (context, index) {
                final medication = prescription.medications[index];
                return _buildMedicationItem(medication, colorScheme, textTheme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(
    PrescriptionMedication medication,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingSM),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication.medicationName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          _buildMedicationDetail('Dosage', medication.dosage, textTheme),
          const SizedBox(height: 4),
          _buildMedicationDetail('Frequency', medication.frequency, textTheme),
          const SizedBox(height: 4),
          _buildMedicationDetail('Duration', medication.duration, textTheme),
          if (medication.instructions != null &&
              medication.instructions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSM),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      medication.instructions!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationDetail(
    String label,
    String value,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(value, style: textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildTestsCard(
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
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
                Icon(Icons.science_outlined, color: colorScheme.tertiary),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Recommended Tests',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prescription.tests.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spacingSM),
              itemBuilder: (context, index) {
                final test = prescription.tests[index];
                return _buildTestItem(test, colorScheme, textTheme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestItem(
    MedicalTest test,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    Color urgencyColor;
    IconData urgencyIcon;

    switch (test.urgency) {
      case 'urgent':
        urgencyColor = Colors.red;
        urgencyIcon = Icons.priority_high;
        break;
      case 'routine':
        urgencyColor = Colors.green;
        urgencyIcon = Icons.check_circle_outline;
        break;
      default:
        urgencyColor = Colors.orange;
        urgencyIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingSM),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: urgencyColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
            ),
            child: Icon(urgencyIcon, color: urgencyColor, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.testName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (test.testReason != null && test.testReason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    test.testReason!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
            ),
            child: Text(
              test.urgency.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: urgencyColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
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
                Icon(Icons.note_outlined, color: colorScheme.primary),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Medical Notes',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(prescription.medicalNotes!, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpCard(
    Prescription prescription,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final dateFormatter = DateFormat('MMMM dd, yyyy');

    return Card(
      elevation: AppConstants.elevationLevel1,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Row(
          children: [
            Icon(Icons.event_available, color: colorScheme.primary, size: 32),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow-up Required',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormatter.format(prescription.followUpDate!.toLocal()),
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildNotFoundState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Prescription Not Found',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Failed to Load Prescription',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.error),
          ),
        ],
      ),
    );
  }
}
