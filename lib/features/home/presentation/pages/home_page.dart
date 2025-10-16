// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/home_widgets.dart';
import '../../../../core/theme/theme.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.lighter_blue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(),
                SizedBox(height: 24),
                UpcomingScheduleSection(),
                SizedBox(height: 24),
                CategoriesSection(),
                SizedBox(height: 24),
                TopDoctorsSection(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
