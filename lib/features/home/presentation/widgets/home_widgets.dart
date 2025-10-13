// lib/features/home/presentation/widgets/home_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                  'Hi, ${user?.firstName ?? 'User'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                loading: () => const Text('Loading...'),
                error: (_, __) => const Text('Hi, User'),
              ),
              Text(
                'How is your health?',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.search, size: 28), onPressed: () {}),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.notifications_none, color: Colors.green),
        ),
      ],
    );
  }
}

class UpcomingScheduleSection extends StatelessWidget {
  const UpcomingScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              AppointmentCard(
                doctorName: 'Dr. Alisa Dewali',
                specialty: 'Cardiovascular',
                date: 'Feb 24, 9:00am',
                imageUrl: 'https://i.pravatar.cc/150?img=47',
                color: Color(0xFF4A90E2),
              ),
              SizedBox(width: 12),
              AppointmentCard(
                doctorName: 'Dr. Ahmed Khan',
                specialty: 'Odontology',
                date: 'Feb 25, 10:30am',
                imageUrl: 'https://i.pravatar.cc/150?img=33',
                color: Color(0xFF5B9FED),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;
  final String imageUrl;
  final Color color;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.imageUrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -10,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: 140,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.white, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  void _showAllCategories(
    BuildContext context,
    List<CategoryModel> categories,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'All Medical Specialties',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          // Show doctors for this specialty
                          _showDoctorsBySpecialty(context, category);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: category.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (category.description != null)
                              Text(
                                category.description!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDoctorsBySpecialty(BuildContext context, CategoryModel category) {
    // Mock data - in a real app, fetch this from API/repository
    final doctors = [
      DoctorBySpecialty(
        name: 'Dr. John Smith',
        specialization: category.specialization,
        hospital: 'City General Hospital',
        rating: 4.8,
        imageUrl: 'https://i.pravatar.cc/150?img=1',
      ),
      DoctorBySpecialty(
        name: 'Dr. Sarah Johnson',
        specialization: category.specialization,
        hospital: 'Medical Center',
        rating: 4.9,
        imageUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      DoctorBySpecialty(
        name: 'Dr. Robert Williams',
        specialization: category.specialization,
        hospital: 'University Hospital',
        rating: 4.7,
        imageUrl: 'https://i.pravatar.cc/150?img=8',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.specialization,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (category.description != null)
                              Text(
                                category.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(doctor.imageUrl),
                          ),
                          title: Text(doctor.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctor.hospital),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  Text(' ${doctor.rating}'),
                                ],
                              ),
                            ],
                          ),
                          trailing: FilledButton(
                            onPressed: () {},
                            child: const Text('Book'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => _showAllCategories(context, categories),
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length > 8 ? 8 : categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CategoryCard(
                  icon: category.icon,
                  label: category.label,
                  color: category.color,
                ),
              );
            },
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
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Icon(icon, color: color, size: 32)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
            const Text(
              'Top Doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF4A90E2),
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
          imageUrl: 'https://i.pravatar.cc/150?img=14',
        ),
        const SizedBox(height: 12),
        const DoctorCard(
          name: 'Dr. Adrian Segara',
          specialty: 'Surgeon',
          hospital: 'Apollo Hospital',
          rating: 4.9,
          reviews: 741,
          imageUrl: 'https://i.pravatar.cc/150?img=13',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$specialty • $hospital',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                            : Colors.grey[300],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($reviews)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
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

class DoctorBySpecialty {
  final String name;
  final String specialization;
  final String hospital;
  final double rating;
  final String imageUrl;

  DoctorBySpecialty({
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.rating,
    required this.imageUrl,
  });
}

final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return [
    CategoryModel(
      icon: FontAwesomeIcons.heartPulse,
      label: 'Cardiology',
      color: Colors.red,
      specialization: 'Cardiologist',
      description: 'Heart conditions and diseases',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.brain,
      label: 'Psychology',
      color: Colors.blue,
      specialization: 'Psychologist',
      description: 'Mental health and emotional wellbeing',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.vialCircleCheck,
      label: 'Pathology',
      color: Colors.purple,
      specialization: 'Pathologist',
      description: 'Disease diagnosis through lab tests',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.lungs,
      label: 'Pulmonology',
      color: Colors.orange,
      specialization: 'Pulmonologist',
      description: 'Respiratory system and lung diseases',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.baby,
      label: 'Pediatrics',
      color: Colors.teal,
      specialization: 'Pediatrician',
      description: 'Child and infant healthcare',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.eye,
      label: 'Ophthalmology',
      color: Colors.indigo,
      specialization: 'Ophthalmologist',
      description: 'Eye care and vision health',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.userDoctor,
      label: 'Surgery',
      color: Colors.red.shade800,
      specialization: 'General Surgeon',
      description: 'Surgical procedures and operations',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.bacteria,
      label: 'Dermatology',
      color: Colors.green,
      specialization: 'Dermatologist',
      description: 'Skin conditions and treatments',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.personPregnant,
      label: 'Gynecology',
      color: Colors.pinkAccent,
      specialization: 'Gynecologist & Obstetrician',
      description: 'Women\'s reproductive health',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.bone,
      label: 'Orthopedics',
      color: Colors.brown,
      specialization: 'Orthopedist',
      description: 'Bone, joint, and muscle health',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.appleWhole,
      label: 'Nutrition',
      color: Colors.lightGreen,
      specialization: 'Clinical Nutritionist',
      description: 'Diet and nutritional health',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.earListen,
      label: 'ENT',
      color: Colors.deepOrange,
      specialization: 'Otolaryngologists (ENT)',
      description: 'Ear, nose, and throat care',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.tooth,
      label: 'Dentistry',
      color: Colors.blue.shade300,
      specialization: 'Dentist & Maxillofacial Surgeon',
      description: 'Oral and dental health',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.kitMedical,
      label: 'Nephrology',
      color: Colors.amber,
      specialization: 'Nephrologist',
      description: 'Kidney diseases and disorders',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.stethoscope,
      label: 'Internal Medicine',
      color: Colors.teal.shade700,
      specialization: 'Internal Medicine Specialist',
      description: 'Adult diseases and conditions',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.dna,
      label: 'Oncology',
      color: Colors.purpleAccent,
      specialization: 'Oncologist',
      description: 'Cancer diagnosis and treatment',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.pills,
      label: 'Gastroenterology',
      color: Colors.amber.shade700,
      specialization: 'Gastroenterologist',
      description: 'Digestive system health',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.brain,
      label: 'Neurology',
      color: Colors.deepPurple,
      specialization: 'Neurologist',
      description: 'Brain and nervous system',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.syringe,
      label: 'Endocrinology',
      color: Colors.cyan,
      specialization: 'Endocrinologist',
      description: 'Hormone-related conditions',
    ),
    CategoryModel(
      icon: FontAwesomeIcons.personWalking,
      label: 'Rehabilitation',
      color: Colors.blueGrey,
      specialization: 'Rehabilitation Specialist',
      description: 'Physical recovery and therapy',
    ),
  ];
});
