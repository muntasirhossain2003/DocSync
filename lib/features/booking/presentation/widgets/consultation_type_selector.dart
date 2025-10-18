// lib/features/booking/presentation/widgets/consultation_type_selector.dart

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_constants.dart';
import '../../domain/models/consultation.dart';
import '../providers/booking_provider.dart';

class ConsultationTypeSelector extends ConsumerWidget {
  const ConsultationTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedType = ref.watch(selectedConsultationTypeProvider);

    return Row(
      children: [
        Expanded(
          child: _buildTypeCard(
            context,
            ref,
            type: ConsultationType.video,
            icon: FluentIcons.video_24_filled,
            label: 'Video',
            isSelected: selectedType == ConsultationType.video,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        SizedBox(width: AppConstants.spacingSM),
        Expanded(
          child: _buildTypeCard(
            context,
            ref,
            type: ConsultationType.audio,
            icon: FluentIcons.call_24_filled,
            label: 'Audio',
            isSelected: selectedType == ConsultationType.audio,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        SizedBox(width: AppConstants.spacingSM),
        Expanded(
          child: _buildTypeCard(
            context,
            ref,
            type: ConsultationType.chat,
            icon: FluentIcons.chat_24_filled,
            label: 'Chat',
            isSelected: selectedType == ConsultationType.chat,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard(
    BuildContext context,
    WidgetRef ref, {
    required ConsultationType type,
    required IconData icon,
    required String label,
    required bool isSelected,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return InkWell(
      onTap: () {
        ref.read(selectedConsultationTypeProvider.notifier).state = type;
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.spacingMD,
          horizontal: AppConstants.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppConstants.spacingXS),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
