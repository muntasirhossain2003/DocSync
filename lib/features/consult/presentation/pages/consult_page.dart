// lib/features/consult/presentation/pages/consult_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/consult_widgets.dart';

class ConsultPage extends ConsumerWidget {
  const ConsultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Column(children: [ConsultSearchBar(), DoctorList()]),
      ),
    );
  }
}
