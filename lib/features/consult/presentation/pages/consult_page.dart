// lib/features/consult/presentation/pages/consult_page.dart
import 'package:flutter/material.dart';

import '../widgets/consult_widgets.dart';

class ConsultPage extends StatelessWidget {
  const ConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Column(children: [ConsultSearchBar(), DoctorList()]),
      ),
    );
  }
}
