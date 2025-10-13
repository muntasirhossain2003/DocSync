import 'package:flutter/material.dart';

import '../widgets/consult_widgets.dart';

class ConsultPage extends StatelessWidget {
  const ConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consult')),
      body: const Column(children: [ConsultSearchBar(), DoctorList()]),
    );
  }
}
