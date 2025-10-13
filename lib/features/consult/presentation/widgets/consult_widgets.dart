// lib/features/consult/presentation/widgets/consult_widgets.dart
import 'package:flutter/material.dart';

class ConsultSearchBar extends StatelessWidget {
  const ConsultSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search doctors, specialization... ',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class DoctorList extends StatelessWidget {
  const DoctorList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: 10,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('Dr. Specialist $index'),
          subtitle: const Text('Specialization • 4.8 ⭐'),
          trailing: Wrap(
            spacing: 8,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Book')),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Instant Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
