import 'package:flutter/material.dart';

import '../widgets/health_widgets.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(title: 'Prescriptions', child: const PrescriptionList()),
          SectionCard(
            title: 'Past Consultations',
            child: const ConsultationList(),
          ),
          SectionCard(title: 'Share with Doctor', child: const ShareSection()),
        ],
      ),
    );
  }
}
