// lib/features/booking/presentation/widgets/doctor_info_card.dart

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_constants.dart';
import '../../../consult/domain/models/doctor.dart';

class DoctorInfoCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorInfoCard({super.key, required this.doctor});

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
        padding: EdgeInsets.all(AppConstants.spacingMD),
        child: Row(
          children: [
            // Doctor Avatar
            CircleAvatar(
              radius: 35,
              backgroundImage: _isValidImageUrl(doctor.profilePictureUrl)
                  ? NetworkImage(doctor.profilePictureUrl!)
                  : null,
              backgroundColor: colorScheme.primaryContainer,
              child: _isValidImageUrl(doctor.profilePictureUrl)
                  ? null
                  : Icon(
                      FluentIcons.doctor_24_regular,
                      size: 35,
                      color: colorScheme.primary,
                    ),
            ),
            SizedBox(width: AppConstants.spacingMD),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.fullName}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingXS),
                  Row(
                    children: [
                      Icon(
                        FluentIcons.stethoscope_24_regular,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: AppConstants.spacingXS),
                      Expanded(
                        child: Text(
                          doctor.specialization,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (doctor.qualification != null) ...[
                    SizedBox(height: AppConstants.spacingXS),
                    Row(
                      children: [
                        Icon(
                          FluentIcons.certificate_24_regular,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: AppConstants.spacingXS),
                        Expanded(
                          child: Text(
                            doctor.qualification!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: AppConstants.spacingSM),
                  Row(
                    children: [
                      Icon(
                        FluentIcons.money_24_regular,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: AppConstants.spacingXS),
                      Text(
                        '৳${doctor.consultationFee.toStringAsFixed(0)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingXS),
                      Text(
                        '/consultation',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidImageUrl(String? url) {
    return url != null &&
        url.isNotEmpty &&
        url != 'https://sasthyaseba.com/default_image_url';
  }
}
