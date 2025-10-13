// lib/features/consult/presentation/widgets/consult_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/doctor_repository.dart';
import '../../domain/models/doctor.dart';
import '../providers/doctor_provider.dart';

class ConsultSearchBar extends ConsumerWidget {
  const ConsultSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search doctors, specialization... ',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}

class DoctorList extends ConsumerWidget {
  const DoctorList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(filteredDoctorsProvider);

    return Expanded(
      child: doctorsAsync.when(
        data: (doctors) {
          if (doctors.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No doctors found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try adjusting your search',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorCard(doctor: doctor);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading doctors',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(filteredDoctorsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Doctor Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      doctor.profilePictureUrl != null &&
                          doctor.profilePictureUrl!.isNotEmpty
                      ? NetworkImage(doctor.profilePictureUrl!)
                      : null,
                  child:
                      doctor.profilePictureUrl == null ||
                          doctor.profilePictureUrl!.isEmpty
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),

                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${doctor.fullName}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (doctor.qualification != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          doctor.qualification!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Availability Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: doctor.isAvailableNow
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: doctor.isAvailableNow
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: doctor.isAvailableNow
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.isAvailableNow ? 'Available' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: doctor.isAvailableNow
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                doctor.bio!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],

            const SizedBox(height: 12),

            // Fee and Actions
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 18,
                  color: Colors.indigo.shade700,
                ),
                Text(
                  '৳${doctor.consultationFee.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/consultation',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),

                // Action Buttons
                OutlinedButton.icon(
                  onPressed: () => _bookConsultation(context, doctor),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Book'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: doctor.isAvailableNow
                      ? () => _instantCall(context, doctor)
                      : null,
                  icon: const Icon(Icons.video_call, size: 18),
                  label: const Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _bookConsultation(BuildContext context, Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BookConsultationSheet(doctor: doctor),
    );
  }

  void _instantCall(BuildContext context, Doctor doctor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting video call with Dr. ${doctor.fullName}...'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Implement video call functionality
  }
}

class BookConsultationSheet extends StatefulWidget {
  final Doctor doctor;

  const BookConsultationSheet({super.key, required this.doctor});

  @override
  State<BookConsultationSheet> createState() => _BookConsultationSheetState();
}

class _BookConsultationSheetState extends State<BookConsultationSheet> {
  String consultationType = 'video';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isBooking = false;

  Future<void> _bookConsultation() async {
    setState(() => isBooking = true);

    try {
      final scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final authUserId = Supabase.instance.client.auth.currentUser?.id;
      if (authUserId == null) {
        throw Exception('User not logged in');
      }

      // Fetch the user's actual ID from the users table
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('auth_id', authUserId)
          .single();

      final userId = userResponse['id'] as String;

      final repository = DoctorRepository();
      await repository.bookConsultation(
        patientId: userId,
        doctorId: widget.doctor.id,
        consultationType: consultationType,
        scheduledTime: scheduledDateTime,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error booking consultation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.doctor.profilePictureUrl != null
                    ? NetworkImage(widget.doctor.profilePictureUrl!)
                    : null,
                child: widget.doctor.profilePictureUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${widget.doctor.fullName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.doctor.specialization,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // Consultation Type
          const Text(
            'Consultation Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'video',
                label: Text('Video'),
                icon: Icon(Icons.videocam),
              ),
              ButtonSegment(
                value: 'audio',
                label: Text('Audio'),
                icon: Icon(Icons.call),
              ),
              ButtonSegment(
                value: 'chat',
                label: Text('Chat'),
                icon: Icon(Icons.chat),
              ),
            ],
            selected: {consultationType},
            onSelectionChanged: (Set<String> selection) {
              setState(() => consultationType = selection.first);
            },
          ),
          const SizedBox(height: 20),

          // Date Selection
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) setState(() => selectedDate = date);
            },
          ),

          // Time Selection
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('Time'),
            subtitle: Text(selectedTime.format(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (time != null) setState(() => selectedTime = time);
            },
          ),
          const SizedBox(height: 20),

          // Book Button
          ElevatedButton(
            onPressed: isBooking ? null : _bookConsultation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isBooking
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Book Consultation - ৳${widget.doctor.consultationFee}'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
