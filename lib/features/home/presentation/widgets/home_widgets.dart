// lib/features/home/presentation/widgets/home_widgets.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../video_call/domain/models/call_state.dart';
import '../pages/all_categories_page.dart';
import '../pages/all_top_doctors_page.dart';
import '../pages/doctors_by_specialty_page.dart';
import '../providers/consultation_provider.dart';
import '../providers/user_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Row(
      children: [
        userAsync.when(
          data: (user) => CircleAvatar(
            radius: 24,
            backgroundImage:
                user?.profilePictureUrl != null &&
                    user!.profilePictureUrl!.isNotEmpty
                ? NetworkImage(user.profilePictureUrl!)
                : null,
            child:
                user?.profilePictureUrl == null ||
                    user!.profilePictureUrl!.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          loading: () => const CircleAvatar(
            radius: 24,
            child: CircularProgressIndicator(),
          ),
          error: (_, __) =>
              const CircleAvatar(radius: 24, child: Icon(Icons.person)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userAsync.when(
                data: (user) => Text(
                  '${AppLocalizations.of(context)!.hi}, ${user?.firstName ?? 'User'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                loading: () => const Text('Loading...'),
                error: (_, __) =>
                    Text('${AppLocalizations.of(context)!.hi}, User'),
              ),
              Text(
                AppLocalizations.of(context)!.howIsYourHealth,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UpcomingScheduleSection extends ConsumerStatefulWidget {
  const UpcomingScheduleSection({super.key});

  @override
  ConsumerState<UpcomingScheduleSection> createState() =>
      _UpcomingScheduleSectionState();
}

class _UpcomingScheduleSectionState
    extends ConsumerState<UpcomingScheduleSection> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to refresh consultations every minute for real-time updates
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        // Refresh the consultation provider to update button states
        ref.invalidate(upcomingConsultationsProvider);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final consultationsAsync = ref.watch(upcomingConsultationsProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.upcomingSchedule,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: const TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        consultationsAsync.when(
          data: (consultations) {
            if (consultations.isEmpty) {
              return Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.noUpcomingSchedule,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: consultations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final consultation = consultations[index];
                  final dateFormatter = DateFormat('MMM dd, h:mma');

                  // Generate color based on index
                  final colors = [
                    const Color(0xFF4A90E2),
                    const Color(0xFF5B9FED),
                    const Color(0xFF6BA3F7),
                    const Color(0xFF7AB5FF),
                    const Color(0xFF89C4FF),
                  ];

                  return AppointmentCard(
                    consultation: consultation,
                    doctorName: consultation.doctor.fullName,
                    specialty: consultation.doctor.specialization,
                    date: dateFormatter.format(
                      consultation.scheduledTime.toLocal(),
                    ),
                    imageUrl: _getValidImageUrl(
                      consultation.doctor.profilePictureUrl,
                      index,
                    ),
                    color: colors[index % colors.length],
                  );
                },
              ),
            );
          },
          loading: () => Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load appointments',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => ref.refresh(upcomingConsultationsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getValidImageUrl(String? profilePictureUrl, int index) {
    // Check if the URL is invalid or the problematic sasthyaseba URL
    if (profilePictureUrl == null ||
        profilePictureUrl.isEmpty ||
        profilePictureUrl == 'https://sasthyaseba.com/default_image_url' ||
        profilePictureUrl.contains('pravatar.cc')) {
      // Return empty string to indicate placeholder should be used
      return '';
    }
    return profilePictureUrl;
  }
}

class AppointmentCard extends StatelessWidget {
  final ConsultationWithDoctor consultation;
  final String doctorName;
  final String specialty;
  final String date;
  final String imageUrl;
  final Color color;

  const AppointmentCard({
    super.key,
    required this.consultation,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.imageUrl,
    required this.color,
  });

  bool get _isValidImageUrl {
    return imageUrl.isNotEmpty &&
        imageUrl != 'https://sasthyaseba.com/default_image_url' &&
        !imageUrl.contains('pravatar.cc');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Round doctor image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _isValidImageUrl
                        ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[400],
                                  size: 30,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: Icon(Icons.person, color: color, size: 30),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctorName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        specialty,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildJoinCallButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinCallButton(BuildContext context) {
    if (consultation.consultationType != 'video') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: RealTimeCallButton(
        consultation: consultation,
        color: color,
        onJoinCall: () => _joinVideoCall(context),
      ),
    );
  }

  void _joinVideoCall(BuildContext context) {
    // Create video call info and navigate
    final callInfo = VideoCallInfo(
      consultationId: consultation.id,
      doctorId: consultation.doctor.id,
      doctorName: consultation.doctor.fullName,
      doctorProfileUrl: consultation.doctor.profilePictureUrl,
      patientId: '', // Will be filled from auth in the video call page
      patientName: '', // Will be filled from auth in the video call page
      scheduledTime: consultation.scheduledTime,
    );

    context.push('/video-call', extra: callInfo);
  }
}

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  void _showAllCategories(BuildContext context) {
    // Navigate to AllCategoriesPage with real data from database
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllCategoriesPage()),
    );
  }

  void _showDoctorsBySpecialty(BuildContext context, CategoryModel category) {
    // Navigate to DoctorsBySpecialtyPage with real data from database
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorsBySpecialtyPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.categories,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => _showAllCategories(context),
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return Container(
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No categories available',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              );
            }

            // Show only first 6 categories in 2x3 grid
            final displayCategories = categories.take(6).toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: displayCategories.length,
              itemBuilder: (context, index) {
                final category = displayCategories[index];
                return GestureDetector(
                  onTap: () => _showDoctorsBySpecialty(context, category),
                  child: CategoryCard(
                    icon: category.icon,
                    label: category.label,
                    color: category.color,
                  ),
                );
              },
            );
          },
          loading: () => Container(
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[300]),
                  const SizedBox(height: 4),
                  Text(
                    'Failed to load categories',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Icon(icon, color: color, size: 28)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class TopDoctorsSection extends StatelessWidget {
  const TopDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.topDoctors,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllTopDoctorsPage(),
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const DoctorCard(
          name: 'Dr. Shakib Khan',
          specialty: 'Dentist',
          hospital: 'Asian Hospital',
          rating: 4.8,
          reviews: 565,
          imageUrl: '', // Use placeholder
        ),
        const SizedBox(height: 12),
        const DoctorCard(
          name: 'Dr. Adrian Segara',
          specialty: 'Surgeon',
          hospital: 'Apollo Hospital',
          rating: 4.9,
          reviews: 741,
          imageUrl: '', // Use placeholder
        ),
      ],
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviews;
  final String imageUrl;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty && !imageUrl.contains('pravatar.cc')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            color: colorScheme.primary,
                            size: 35,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        color: colorScheme.primary,
                        size: 35,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$specialty • $hospital',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 14,
                        color: index < rating.floor()
                            ? Colors.amber
                            : colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($reviews)',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: colorScheme.onSurface.withOpacity(0.5)),
        ],
      ),
    );
  }
}

// Models and Providers
class CategoryModel {
  final dynamic icon; // Can be IconData or IconData from FontAwesomeIcons
  final String label;
  final Color color;
  final String specialization;
  final String? description;

  CategoryModel({
    required this.icon,
    required this.label,
    required this.color,
    required this.specialization,
    this.description,
  });
}

// Fetch all unique specializations from the database
final allSpecializationsProvider = FutureProvider<List<String>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('doctors')
        .select('specialization')
        .order('specialization');

    // Extract unique specializations
    final specializations = <String>{};
    for (final row in response as List) {
      final spec = row['specialization'] as String?;
      if (spec != null && spec.isNotEmpty) {
        specializations.add(spec);
      }
    }

    return specializations.toList()..sort();
  } catch (e) {
    return [];
  }
});

// Map specialization to icon and color
IconData _getIconForSpecialization(String specialization) {
  final lower = specialization.toLowerCase();

  if (lower.contains('cardio')) return FontAwesomeIcons.heartPulse;
  if (lower.contains('psycho') || lower.contains('psychiatr'))
    return FontAwesomeIcons.brain;
  if (lower.contains('patho')) return FontAwesomeIcons.vialCircleCheck;
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
  if (lower.contains('nutrit')) return FontAwesomeIcons.appleWhole;
  if (lower.contains('ent') ||
      lower.contains('otolaryng') ||
      lower.contains('ear'))
    return FontAwesomeIcons.earListen;
  if (lower.contains('dent') || lower.contains('maxillofacial'))
    return FontAwesomeIcons.tooth;
  if (lower.contains('nephro') || lower.contains('kidney'))
    return FontAwesomeIcons.kitMedical;
  if (lower.contains('internal medicine') ||
      lower.contains('medicine specialist') ||
      lower.contains('general physician'))
    return FontAwesomeIcons.stethoscope;
  if (lower.contains('oncol') || lower.contains('cancer'))
    return FontAwesomeIcons.dna;
  if (lower.contains('gastro') ||
      lower.contains('digest') ||
      lower.contains('hepato') ||
      lower.contains('colorectal'))
    return FontAwesomeIcons.pills;
  if (lower.contains('neuro') && !lower.contains('surgeon'))
    return FontAwesomeIcons.brain;
  if (lower.contains('endocrin') ||
      lower.contains('diabetes') ||
      lower.contains('hormone'))
    return FontAwesomeIcons.syringe;
  if (lower.contains('rehab') ||
      lower.contains('physical medicine') ||
      lower.contains('physiotherap'))
    return FontAwesomeIcons.personWalking;
  if (lower.contains('anesthe')) return FontAwesomeIcons.syringe;
  if (lower.contains('urolog') || lower.contains('urinary'))
    return FontAwesomeIcons.droplet;
  if (lower.contains('sono') || lower.contains('radiolog'))
    return FontAwesomeIcons.xRay;
  if (lower.contains('hematol') || lower.contains('blood'))
    return FontAwesomeIcons.droplet;
  if (lower.contains('rheumat') || lower.contains('arthrit'))
    return FontAwesomeIcons.bone;
  if (lower.contains('infertil')) return FontAwesomeIcons.personPregnant;
  if (lower.contains('vascular')) return FontAwesomeIcons.heartPulse;
  if (lower.contains('critical care') || lower.contains('intensive'))
    return FontAwesomeIcons.briefcaseMedical;
  if (lower.contains('pain')) return FontAwesomeIcons.handHoldingMedical;
  if (lower.contains('plastic')) return FontAwesomeIcons.scissors;
  if (lower.contains('thoracic')) return FontAwesomeIcons.lungs;
  if (lower.contains('family medicine')) return FontAwesomeIcons.houseMedical;
  if (lower.contains('laparoscop')) return FontAwesomeIcons.userDoctor;

  return FontAwesomeIcons.userDoctor; // Default icon
}

Color _getColorForSpecialization(String specialization) {
  final lower = specialization.toLowerCase();

  if (lower.contains('cardio') || lower.contains('vascular')) return Colors.red;
  if (lower.contains('psycho') || lower.contains('psychiatr'))
    return Colors.blue;
  if (lower.contains('patho')) return Colors.purple;
  if (lower.contains('pulmo') ||
      lower.contains('respiratory') ||
      lower.contains('chest'))
    return Colors.orange;
  if (lower.contains('pediatric') || lower.contains('neonat'))
    return Colors.teal;
  if (lower.contains('ophthalmo')) return Colors.indigo;
  if (lower.contains('surgeon') || lower.contains('surgery'))
    return Colors.red.shade800;
  if (lower.contains('dermat')) return Colors.green;
  if (lower.contains('gyneco') ||
      lower.contains('obstetric') ||
      lower.contains('infertil'))
    return Colors.pinkAccent;
  if (lower.contains('orthoped') ||
      lower.contains('bone') ||
      lower.contains('rheumat'))
    return Colors.brown;
  if (lower.contains('nutrit')) return Colors.lightGreen;
  if (lower.contains('ent') || lower.contains('otolaryng'))
    return Colors.deepOrange;
  if (lower.contains('dent') || lower.contains('maxillofacial'))
    return Colors.blue.shade300;
  if (lower.contains('nephro') || lower.contains('urolog')) return Colors.amber;
  if (lower.contains('internal medicine') ||
      lower.contains('general physician'))
    return Colors.teal.shade700;
  if (lower.contains('oncol')) return Colors.purpleAccent;
  if (lower.contains('gastro') ||
      lower.contains('hepato') ||
      lower.contains('colorectal'))
    return Colors.amber.shade700;
  if (lower.contains('neuro') && !lower.contains('surgeon'))
    return Colors.deepPurple;
  if (lower.contains('endocrin') || lower.contains('diabetes'))
    return Colors.cyan;
  if (lower.contains('rehab') || lower.contains('physiotherap'))
    return Colors.blueGrey;
  if (lower.contains('anesthe')) return Colors.grey;
  if (lower.contains('sono') || lower.contains('radiolog'))
    return Colors.indigo.shade300;
  if (lower.contains('hematol')) return Colors.red.shade400;
  if (lower.contains('critical care')) return Colors.red.shade900;
  if (lower.contains('pain')) return Colors.orange.shade700;
  if (lower.contains('plastic')) return Colors.pink;
  if (lower.contains('thoracic')) return Colors.blue.shade700;
  if (lower.contains('family medicine')) return Colors.green.shade700;

  return Colors.blueAccent; // Default color
}

// Create categories from database specializations
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final specializations = await ref.watch(allSpecializationsProvider.future);

  return specializations.map((spec) {
    return CategoryModel(
      icon: _getIconForSpecialization(spec),
      label: _formatSpecializationLabel(spec),
      color: _getColorForSpecialization(spec),
      specialization: spec, // Use exact database value
      description: null,
    );
  }).toList();
});

// Format specialization for display (shorten long names)
String _formatSpecializationLabel(String specialization) {
  // Remove common suffixes for shorter display
  String label = specialization
      .replaceAll(' Specialist', '')
      .replaceAll(' & ', ' & ');

  // Shorten very long names
  if (label.length > 20) {
    // Try to abbreviate common terms
    label = label
        .replaceAll('Pediatric ', 'Ped. ')
        .replaceAll('Gynecologist & Obstetrician', 'Gyn & Obs')
        .replaceAll('Otolaryngologists (ENT)', 'ENT')
        .replaceAll('Critical Care Medicine', 'Critical Care')
        .replaceAll('Internal Medicine', 'Int. Medicine');
  }

  return label;
}

// Real-time call button with live countdown updates
class RealTimeCallButton extends StatefulWidget {
  final ConsultationWithDoctor consultation;
  final Color color;
  final VoidCallback onJoinCall;

  const RealTimeCallButton({
    super.key,
    required this.consultation,
    required this.color,
    required this.onJoinCall,
  });

  @override
  State<RealTimeCallButton> createState() => _RealTimeCallButtonState();
}

class _RealTimeCallButtonState extends State<RealTimeCallButton> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every 30 seconds for more responsive UI
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild with updated time calculations
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canJoin = widget.consultation.isVideoCallAvailable;
    final buttonText = widget.consultation.callStatusText;

    // Determine icon based on consultation state
    IconData buttonIcon;
    if (canJoin) {
      buttonIcon = Icons.video_call;
    } else if (widget.consultation.timeUntilAvailable != null) {
      buttonIcon = Icons.schedule;
    } else {
      buttonIcon = Icons.call_end;
    }

    return ElevatedButton.icon(
      onPressed: canJoin ? widget.onJoinCall : null,
      icon: Icon(buttonIcon, size: 18),
      label: Text(
        buttonText,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: canJoin ? Colors.white : Colors.white.withOpacity(0.5),
        foregroundColor: canJoin ? widget.color : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
