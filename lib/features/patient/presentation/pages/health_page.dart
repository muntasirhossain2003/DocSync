import 'package:flutter/material.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Prescriptions',
            child: Column(
              children: const [
                ListTile(
                  title: Text('Amoxicillin 500mg'),
                  subtitle: Text('05 May 2025'),
                  trailing: Icon(Icons.download),
                ),
                ListTile(
                  title: Text('Vitamin D'),
                  subtitle: Text('12 Apr 2025'),
                  trailing: Icon(Icons.download),
                ),
              ],
            ),
          ),
          _SectionCard(
            title: 'Past Consultations',
            child: Column(
              children: const [
                ListTile(
                  title: Text('Dr. Jane Doe'),
                  subtitle: Text('Video • 20 Apr 2025'),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  title: Text('Dr. Ahmed Khan'),
                  subtitle: Text('In-clinic • 02 Mar 2025'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          _SectionCard(
            title: 'Share with Doctor',
            child: Row(
              children: [
                Expanded(
                  child: Text('Allow access to your EHR for selected doctors'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Share')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
