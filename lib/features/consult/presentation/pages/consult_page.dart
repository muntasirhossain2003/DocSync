// lib/features/consult/presentation/pages/consult_page.dart
import 'package:flutter/material.dart';

import '../widgets/consult_widgets.dart';

class ConsultPage extends StatelessWidget {
  const ConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Column(children: [ConsultSearchBar(), DoctorList()]),
      ),
    );
  }
}
