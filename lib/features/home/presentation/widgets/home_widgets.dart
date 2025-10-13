// lib/features/home/presentation/widgets/home_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            backgroundImage: user?.profilePictureUrl != null
                ? NetworkImage(user!.profilePictureUrl!)
                : const AssetImage('assets/placeholder.png') as ImageProvider,
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
  final IconData icon;
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
    return Container(
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
            child: Icon(icon, color: color, size: 32),
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
  final IconData icon;
  final String label;
  final Color color;
  final String specialization;

  CategoryModel({
    required this.icon,
    required this.label,
    required this.color,
    required this.specialization,
  });
}

final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return [
    CategoryModel(
      icon: Icons.favorite,
      label: 'Cardiology',
      color: Colors.pink,
      specialization: 'Cardiologist',
    ),
    CategoryModel(
      icon: Icons.psychology,
      label: 'Psychologist',
      color: Colors.blue,
      specialization: 'Psychologist',
    ),
    CategoryModel(
      icon: Icons.science,
      label: 'Quick Test',
      color: Colors.purple,
      specialization: 'Pathologist',
    ),
    CategoryModel(
      icon: Icons.coronavirus,
      label: 'Covid 19',
      color: Colors.orange,
      specialization: 'Pulmonologist',
    ),
    CategoryModel(
      icon: Icons.child_care,
      label: 'Pediatrics',
      color: Colors.teal,
      specialization: 'Pediatrician',
    ),
    CategoryModel(
      icon: Icons.remove_red_eye,
      label: 'Ophthalmology',
      color: Colors.indigo,
      specialization: 'Ophthalmologist',
    ),
    CategoryModel(
      icon: Icons.medical_services,
      label: 'Surgery',
      color: Colors.red,
      specialization: 'General Surgeon',
    ),
    CategoryModel(
      icon: Icons.face,
      label: 'Dermatology',
      color: Colors.green,
      specialization: 'Dermatologist',
    ),
    CategoryModel(
      icon: Icons.pregnant_woman,
      label: 'Gynecology',
      color: Colors.pinkAccent,
      specialization: 'Gynecologist',
    ),
    CategoryModel(
      icon: Icons.healing,
      label: 'Orthopedics',
      color: Colors.brown,
      specialization: 'Orthopedist',
    ),
    CategoryModel(
      icon: Icons.restaurant,
      label: 'Nutrition',
      color: Colors.lightGreen,
      specialization: 'Clinical Nutritionist',
    ),
    CategoryModel(
      icon: Icons.hearing,
      label: 'ENT',
      color: Colors.deepOrange,
      specialization: 'Otolaryngologists (ENT)',
    ),
  ];
});
