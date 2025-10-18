// lib/features/ai_assistant/presentation/widgets/specialist_recommendation_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SpecialistRecommendationCard extends StatelessWidget {
  final String specialization;
  final String? reasoning;
  final VoidCallback onTap;

  const SpecialistRecommendationCard({
    super.key,
    required this.specialization,
    this.reasoning,
    required this.onTap,
  });

  // Get icon based on specialization
  IconData _getIconForSpecialization(String specialization) {
    final lower = specialization.toLowerCase();

    if (lower.contains('cardio')) return FontAwesomeIcons.heartPulse;
    if (lower.contains('psycho') || lower.contains('psychiatr'))
      return FontAwesomeIcons.brain;
    if (lower.contains('pulmo') ||
        lower.contains('respiratory') ||
        lower.contains('chest') ||
        lower.contains('lung'))
      return FontAwesomeIcons.lungs;
    if (lower.contains('pediatric') || lower.contains('neonat'))
      return FontAwesomeIcons.baby;
    if (lower.contains('ophthalmo') || lower.contains('eye'))
      return FontAwesomeIcons.eye;
    if (lower.contains('surgeon') || lower.contains('surgery'))
      return FontAwesomeIcons.userDoctor;
    if (lower.contains('dermat') || lower.contains('skin'))
      return FontAwesomeIcons.bacteria;
    if (lower.contains('gyneco') || lower.contains('obstetric'))
      return FontAwesomeIcons.personPregnant;
    if (lower.contains('orthoped') || lower.contains('bone'))
      return FontAwesomeIcons.bone;
    if (lower.contains('neuro') && !lower.contains('surgeon'))
      return FontAwesomeIcons.brain;
    if (lower.contains('ent') ||
        lower.contains('otolaryng') ||
        lower.contains('ear'))
      return FontAwesomeIcons.earListen;
    if (lower.contains('dent')) return FontAwesomeIcons.tooth;
    if (lower.contains('gastro') || lower.contains('digest'))
      return FontAwesomeIcons.pills;
    if (lower.contains('urolog')) return FontAwesomeIcons.droplet;

    return FontAwesomeIcons.userDoctor; // Default icon
  }

  // Get color based on specialization
  Color _getColorForSpecialization(String specialization) {
    final lower = specialization.toLowerCase();

    if (lower.contains('cardio')) return Colors.red;
    if (lower.contains('psycho') || lower.contains('psychiatr'))
      return Colors.blue;
    if (lower.contains('pulmo') || lower.contains('respiratory'))
      return Colors.orange;
    if (lower.contains('pediatric')) return Colors.teal;
    if (lower.contains('ophthalmo')) return Colors.indigo;
    if (lower.contains('surgeon')) return Colors.red.shade800;
    if (lower.contains('dermat')) return Colors.green;
    if (lower.contains('gyneco') || lower.contains('obstetric'))
      return Colors.pinkAccent;
    if (lower.contains('orthoped') || lower.contains('bone'))
      return Colors.brown;
    if (lower.contains('neuro')) return Colors.deepPurple;
    if (lower.contains('ent')) return Colors.deepOrange;
    if (lower.contains('dent')) return Colors.blue.shade300;
    if (lower.contains('urolog')) return Colors.amber;
    if (lower.contains('gastro')) return Colors.amber.shade700;

    return const Color(0xFF4A90E2); // Default color
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForSpecialization(specialization);
    final icon = _getIconForSpecialization(specialization);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        color.withOpacity(0.2),
                        colorScheme.surfaceContainerHighest,
                      ]
                    : [color.withOpacity(0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(isDark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.psychology,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Recommended Specialist',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  specialization,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? color.withOpacity(0.9)
                                        : color,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View Doctors',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (reasoning != null && reasoning!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.blue.withOpacity(0.15)
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.blue.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: isDark
                              ? Colors.blue.shade300
                              : Colors.blue.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Why this specialist?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.blue.shade200
                                      : Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reasoning!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.blue.shade300
                                      : Colors.blue.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
